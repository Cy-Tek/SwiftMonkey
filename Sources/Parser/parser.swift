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

  func tokenLiteral() -> String {
    switch self {
    case .letStatement(let statement):
      return statement.tokenLiteral()
    }
  }
}

public enum Expression: Node {
  case identifier(Identifier)

  func tokenLiteral() -> String {
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

  init(input: String) {
    lexer = Lexer(input: input)

    // Read the first two tokens into memory
    nextToken()
    nextToken()
  }

  public func parseProgram() throws -> Program {
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
    default: nil
    }
  }

  func parseLetStatment() -> Statement? {
    let token = curToken

    guard expectPeek(expected: .ident) else {
      return nil
    }

    let name = Identifier(token: curToken, value: curToken.literal)

    while !curTokenIs(.semicolon) {
      nextToken()
    }

    return .letStatement(LetStatement(token: token, name: name, value: nil))
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
      return false
    }

    nextToken()
    return true
  }
}
