import Lexer

public struct BlockStatement: Node {
  public let token: Token
  public let statements: [Statement]

  public init(token: Token, statements: [Statement]) {
    self.token = token
    self.statements = statements
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
