import Lexer

protocol Node {
  func tokenLiteral() -> String
}

public enum ParsingError: Error {
  case unimplemented
  case unexpectedToken(expected: String, found: String)
}

public enum Statement: Node {
  case letStatement(LetStatement)
  case returnStatement(ReturnStatement)

  public func tokenLiteral() -> String {
    switch self {
    case .letStatement(let statement):
      return statement.tokenLiteral()
    case .returnStatement(let statement):
      return statement.tokenLiteral()
    }
  }
}

public enum Expression: Node {
  case identifier(Identifier)

  public func tokenLiteral() -> String {
    switch self {
    case .identifier(let expression):
      return expression.tokenLiteral()
    }
  }
}

public class Parser {
  var lexer: Lexer
  var curToken: Token = Token()
  var peekToken: Token = Token()

  public private(set) var errors: [String] = []

  init(input: String) {
    lexer = Lexer(input: input)

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
    default: nil
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
}
