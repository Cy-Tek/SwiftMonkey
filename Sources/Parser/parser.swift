import Lexer

protocol Node {
  func tokenLiteral() -> String
}

public enum ParsingError: Error {
  case unimplemented
  case unexpectedToken(expected: String, found: String)
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

public enum Statement: Node {
  case letStatement(LetStatement)
  case returnStatement(ReturnStatement)
  case expressionStatement(ExpressionStatement)

  public func tokenLiteral() -> String {
    switch self {
    case .letStatement(let statement):
      return statement.tokenLiteral()
    case .returnStatement(let statement):
      return statement.tokenLiteral()
    case .expressionStatement(let statement):
      return statement.tokenLiteral()
    }
  }
}

extension Statement: CustomStringConvertible {
  public var description: String {
    switch self {
    case .letStatement(let statement):
      return statement.description
    case .returnStatement(let statement):
      return statement.description
    case .expressionStatement(let statement):
      return statement.description
    }
  }
}

public enum Expression: Node {
  case identifier(Identifier)
  case integer(IntegerLiteral)

  public func tokenLiteral() -> String {
    switch self {
    case .identifier(let expr):
      return expr.tokenLiteral()
    case .integer(let expr):
      return expr.tokenLiteral()
    }
  }
}

extension Expression: CustomStringConvertible {
  public var description: String {
    switch self {
    case .identifier(let expr):
      return expr.description
    case .integer(let expr):
      return expr.description
    }
  }
}

typealias PrefixParseFn = () -> Expression?
typealias InfixParseFn = (Expression) -> Expression?

public class Parser {
  var lexer: Lexer
  var curToken: Token = Token()
  var peekToken: Token = Token()

  var prefixParseFns: [TokenType: PrefixParseFn] = [:]
  var infixParseFns: [TokenType: InfixParseFn] = [:]

  public private(set) var errors: [String] = []

  init(input: String) {
    lexer = Lexer(input: input)

    registerPrefix(tokenType: .ident, fn: parseIdentifier)
    registerPrefix(tokenType: .int, fn: parseIntegerLiteral)

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

    while !curTokenIs(.semicolon) {
      nextToken()
    }

    return .letStatement(LetStatement(token: token, name: name, value: nil))
  }

  func parseReturnStatement() -> Statement? {
    let returnStmt = ReturnStatement(token: curToken, value: nil)

    nextToken()
    while !curTokenIs(.semicolon) {
      nextToken()
    }

    return .returnStatement(returnStmt)
  }

  func parseExpressionStatement() -> Statement? {
    let token = curToken
    let expression = parseExpression(precedence: .lowest)

    if peekTokenIs(.semicolon) {
      nextToken()
    }

    return .expressionStatement(ExpressionStatement(token: token, expression: expression))
  }

  func parseExpression(precedence: Precedence) -> Expression? {
    guard let prefix = prefixParseFns[curToken.type] else {
      errors.append("No prefix parse function for \(curToken.type)")
      return nil
    }

    var leftExp = prefix()

    /* while !peekTokenIs(.semicolon) && precedence < Precedence.lowest {
      guard let infix = infixParseFns[peekToken.type] else {
        return leftExp
      }

      nextToken()

      leftExp = infix(leftExp)
    } */

    return leftExp
  }

  func parseIdentifier() -> Expression? {
    return .identifier(Identifier(token: curToken, value: curToken.literal))
  }

  func parseIntegerLiteral() -> Expression? {
    guard let value = Int(curToken.literal) else {
      errors.append("Could not parse \(curToken.literal) as an integer")
      return nil
    }

    return .integer(IntegerLiteral(token: curToken, value: value))
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

  private func registerPrefix(tokenType: TokenType, fn: @escaping PrefixParseFn) {
    prefixParseFns[tokenType] = fn
  }

  private func registerInfix(tokenType: TokenType, fn: @escaping InfixParseFn) {
    infixParseFns[tokenType] = fn
  }
}
