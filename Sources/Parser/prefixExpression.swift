import Lexer

public struct PrefixExpression: Node {
  public let token: Token
  public let op: String
  public let right: Expression?

  public func tokenLiteral() -> String {
    return token.literal
  }
}

extension PrefixExpression: CustomStringConvertible {
  public var description: String {
    return "(\(op)\(right?.description ?? ""))"
  }
}
