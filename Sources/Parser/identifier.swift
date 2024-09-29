import Lexer

public struct Identifier: ASTExpression {
  public let token: Token
  public let value: String

  public func tokenLiteral() -> String {
    return token.literal
  }
}

extension Identifier: CustomStringConvertible {
  public var description: String {
    return value
  }
}
