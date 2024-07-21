import Lexer

public struct Identifier: Node {
  public let token: Token
  public let value: String

  func tokenLiteral() -> String {
    return token.literal
  }
}
