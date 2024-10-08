import Lexer

public struct BooleanLiteral: ASTExpression {
  public let token: Token
  public let value: Bool

  public init(token: Token, value: Bool) {
    self.token = token
    self.value = value
  }

  public func tokenLiteral() -> String {
    return token.literal
  }
}

extension BooleanLiteral: CustomStringConvertible {
  public var description: String {
    return token.literal
  }
}
