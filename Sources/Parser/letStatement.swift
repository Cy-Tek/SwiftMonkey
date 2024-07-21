import Lexer

public struct LetStatement: Node {
  public let token: Token
  public let name: Identifier
  public let value: Expression?

  func tokenLiteral() -> String {
    return token.literal
  }
}
