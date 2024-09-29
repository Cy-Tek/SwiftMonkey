import Lexer

public struct PrefixExpression: ASTExpression {
  public let token: Token
  public let op: String
  public let right: ASTExpression?

  public func tokenLiteral() -> String {
    return token.literal
  }
}

extension PrefixExpression: CustomStringConvertible {
  public var description: String {
    return "(\(op)\(right?.description ?? ""))"
  }
}
