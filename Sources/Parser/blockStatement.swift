import Lexer

public struct BlockStatement: Statement {
  public let token: Token
  private(set) public var statements: [Statement]

  public init(token: Token, statements: [Statement]) {
    self.token = token
    self.statements = statements
  }

  public mutating func append(_ item: Statement) {
    statements.append(item)
  }

  public func tokenLiteral() -> String {
    return token.literal
  }
}

extension BlockStatement: CustomStringConvertible {
  public var description: String {
    return statements.reduce("") { $0 + $1.description }
  }
}
