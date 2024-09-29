import Lexer

public protocol Node {
  func tokenLiteral() -> String
}

public enum ParsingError: Error {
  case unimplemented
  case unexpectedToken(expected: String, found: String)
  case unexpectedExpressionType(expected: String, found: String)
}

public enum Precedence: Int, Comparable {
  case lowest = 1
  case equals
  case lessGreater
  case sum
  case product
  case prefix
  case call

  public static func < (lhs: Precedence, rhs: Precedence) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

public protocol Statement: Node, CustomStringConvertible {}
public protocol ASTExpression: Node, CustomStringConvertible {}

typealias PrefixParseFn = () -> ASTExpression?
typealias InfixParseFn = (ASTExpression) -> ASTExpression?

private enum Precedences {
  static let precedences: [TokenType: Precedence] = [
    .equal: .equals,
    .not_equal: .equals,
    .lt: .lessGreater,
    .gt: .lessGreater,
    .plus: .sum,
    .minus: .sum,
    .slash: .product,
    .asterisk: .product,
    .l_paren: .call,
  ]

  public static func lookup(for tokenType: TokenType) -> Precedence {
    return precedences[tokenType] ?? .lowest
  }
}

public class Parser {
  var lexer: Lexer
  var curToken: Token = Token()
  var peekToken: Token = Token()

  var prefixParseFns: [TokenType: PrefixParseFn] = [:]
  var infixParseFns: [TokenType: InfixParseFn] = [:]

  public private(set) var errors: [String] = []

  public init(input: String) {
    lexer = Lexer(input: input)

    registerPrefix(tokenType: .ident, fn: parseIdentifier)
    registerPrefix(tokenType: .int, fn: parseIntegerLiteral)
    registerPrefix(tokenType: .bang, fn: parsePrefixExpression)
    registerPrefix(tokenType: .minus, fn: parsePrefixExpression)
    registerPrefix(tokenType: .true, fn: parseBooleanLiteral)
    registerPrefix(tokenType: .false, fn: parseBooleanLiteral)
    registerPrefix(tokenType: .l_paren, fn: parseGroupedExpression)
    registerPrefix(tokenType: .if, fn: parseIfExpression)
    registerPrefix(tokenType: .function, fn: parseFnExpression)

    registerInfix(tokenType: .plus, fn: parseInfixExpression)
    registerInfix(tokenType: .minus, fn: parseInfixExpression)
    registerInfix(tokenType: .asterisk, fn: parseInfixExpression)
    registerInfix(tokenType: .slash, fn: parseInfixExpression)
    registerInfix(tokenType: .gt, fn: parseInfixExpression)
    registerInfix(tokenType: .lt, fn: parseInfixExpression)
    registerInfix(tokenType: .equal, fn: parseInfixExpression)
    registerInfix(tokenType: .not_equal, fn: parseInfixExpression)
    registerInfix(tokenType: .l_paren, fn: parseCallExpression)

    // Read the first two tokens into memory
    nextToken()
    nextToken()
  }

  public func parseProgram() -> Program {
    let program = Program()

    while curToken.type != .eof {
      if let stmt = parseStatement() {
        program.statements.append(stmt)
      }

      nextToken()
    }

    return program
  }

  func parseStatement() -> Statement? {
    return switch curToken.type {
    case .let: parseLetStatment()
    case .return: parseReturnStatement()
    default: parseExpressionStatement()
    }
  }

  func parseLetStatment() -> Statement? {
    let token = curToken

    guard expectPeek(expected: .ident) else {
      return nil
    }

    let name = Identifier(token: curToken, value: curToken.literal)

    guard expectPeek(expected: .assign) else {
      return nil
    }

    nextToken()
    guard let value = parseExpression(precedence: .lowest) else {
      errors.append("Failed to find a valid expression after `=` symbol in let statement.")
      return nil
    }

    if peekTokenIs(.semicolon) {
      nextToken()
    }

    return LetStatement(token: token, name: name, value: value)
  }

  func parseReturnStatement() -> Statement? {
    let token = curToken

    nextToken()
    guard let value = parseExpression(precedence: .lowest) else {
      errors.append("Failed to find a valid expression after `return` keyword.")
      return nil
    }

    if peekTokenIs(.semicolon) {
      nextToken()
    }

    return ReturnStatement(token: token, value: value)
  }

  func parseExpressionStatement() -> Statement? {
    let token = curToken
    let expression = parseExpression(precedence: .lowest)

    if peekTokenIs(.semicolon) {
      nextToken()
    }

    guard let expression else { return nil }
    return ExpressionStatement(token: token, expression: expression)
  }

  func parseBlockStatement() -> BlockStatement? {
    var blockStatement = BlockStatement(token: curToken, statements: [])

    nextToken()

    while !curTokenIs(.r_brace) && !curTokenIs(.eof) {
      if let stmt = parseStatement() {
        blockStatement.append(stmt)
      }

      nextToken()
    }

    return blockStatement
  }

  func parseExpression(precedence: Precedence) -> ASTExpression? {
    guard let prefix = prefixParseFns[curToken.type] else {
      errors.append("No prefix parse function for \(curToken.type)")
      return nil
    }

    guard var leftExp = prefix() else {
      return nil
    }

    while !peekTokenIs(.semicolon) && precedence < peekPrecedence() {
      guard let infix = infixParseFns[peekToken.type] else {
        return leftExp
      }

      nextToken()
      leftExp = infix(leftExp)!
    }

    return leftExp
  }

  func parseGroupedExpression() -> ASTExpression? {
    nextToken()

    let exp = parseExpression(precedence: .lowest)
    guard expectPeek(expected: .r_paren) else {
      return nil
    }

    return exp
  }

  func parseIdentifier() -> ASTExpression? {
    return Identifier(token: curToken, value: curToken.literal)
  }

  func parseIntegerLiteral() -> ASTExpression? {
    guard let value = Int(curToken.literal) else {
      errors.append("Could not parse \(curToken.literal) as an integer")
      return nil
    }

    return IntegerLiteral(token: curToken, value: value)
  }

  func parseBooleanLiteral() -> ASTExpression? {
    guard let value = Bool(curToken.literal) else {
      errors.append("Could not parse \(curToken.literal) as a boolean")
      return nil
    }

    return BooleanLiteral(token: curToken, value: value)
  }

  func parsePrefixExpression() -> ASTExpression? {
    let token = curToken
    let op = curToken.literal

    nextToken()

    let right = parseExpression(precedence: .prefix)

    return PrefixExpression(token: token, op: op, right: right)
  }

  func parseInfixExpression(left: ASTExpression?) -> ASTExpression? {
    let token = curToken
    let op = curToken.literal

    let precedence = curPrecedence()
    nextToken()
    let right = parseExpression(precedence: precedence)

    return InfixExpression(token: token, left: left, op: op, right: right)
  }

  func parseIfExpression() -> ASTExpression? {
    let token = curToken

    guard expectPeek(expected: .l_paren) else { return nil }
    nextToken()

    guard let condition = parseExpression(precedence: .lowest) else { return nil }

    guard expectPeek(expected: .r_paren) else {
      return nil
    }

    guard expectPeek(expected: .l_brace) else {
      return nil
    }

    guard let consequence = parseBlockStatement() else {
      return nil
    }

    var alternative: BlockStatement?
    if peekTokenIs(.else) {
      nextToken()

      guard expectPeek(expected: .l_brace) else {
        return nil
      }

      alternative = parseBlockStatement()
    }

    return IfExpression(
      token: token, condition: condition, consequence: consequence, alternative: alternative)
  }

  func parseFnExpression() -> ASTExpression? {
    let token = curToken
    var params: [Identifier] = []

    guard expectPeek(expected: .l_paren) else { return nil }
    nextToken()

    while curToken.type != .r_paren {
      guard let ident = parseIdentifier() as? Identifier else {
        errors.append(
          "Attempted to read an identifier while parsing fn parameters, but received a different token type."
        )
        return nil
      }

      params.append(ident)
      nextToken()

      if curTokenIs(.comma) {
        nextToken()
        continue
      }

      guard curTokenIs(.r_paren) else {
        errors.append("Expected either a `comma` or `r_paren`, but received \(peekToken.type)")
        return nil
      }
    }

    guard expectPeek(expected: .l_brace) else { return nil }
    let body = parseBlockStatement()

    return FunctionLiteral(token: token, params: params, body: body)
  }

  func parseCallExpression(left: ASTExpression?) -> ASTExpression? {
    guard let fn = left else { return nil }

    do {
      var callExpr = try CallExpression(token: curToken, fn: fn)

      if peekTokenIs(.r_paren) {
        nextToken()
        return callExpr
      }

      while !curTokenIs(.r_paren) {
        nextToken()

        if let expr = parseExpression(precedence: .lowest) {
          callExpr.addArg(expr)
        }

        nextToken()
        guard curTokenIs(.comma) || curTokenIs(.r_paren) else {
          errors.append("Expected to find a `comma` or `r_paren`, but received \(peekToken.type)")
          return nil
        }
      }

      return callExpr
    } catch ParsingError.unexpectedExpressionType(expected: let expected, found: let found) {
      errors.append("Expected expression type \(expected), but instead found: \(found)")
      return nil
    } catch {
      errors.append("Unexpected error when creating a call expression")
      return nil
    }
  }

  func nextToken() {
    curToken = peekToken
    peekToken = lexer.nextToken()
  }

  func curTokenIs(_ type: TokenType) -> Bool {
    return curToken.type == type
  }

  func peekTokenIs(_ type: TokenType) -> Bool {
    return peekToken.type == type
  }

  func expectPeek(expected: TokenType) -> Bool {
    guard peekTokenIs(expected) else {
      errors.append(
        "Expected next token to be \(expected), but received \(peekToken.type)"
      )
      return false
    }

    nextToken()
    return true
  }

  func peekPrecedence() -> Precedence {
    return Precedences.lookup(for: peekToken.type)
  }

  func curPrecedence() -> Precedence {
    return Precedences.lookup(for: curToken.type)
  }

  private func registerPrefix(tokenType: TokenType, fn: @escaping PrefixParseFn) {
    prefixParseFns[tokenType] = fn
  }

  private func registerInfix(tokenType: TokenType, fn: @escaping InfixParseFn) {
    infixParseFns[tokenType] = fn
  }
}
