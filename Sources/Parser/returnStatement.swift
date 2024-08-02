import Lexer

public struct ReturnStatement: Node {
  public let token: Token
  public let value: Expression

  public func tokenLiteral() -> String {
    return token.literal
  }
}

extension ReturnStatement: CustomStringConvertible {
  public var description: String {
    return "\(tokenLiteral()) \(value);"
  }
}
