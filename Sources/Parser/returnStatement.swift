import Lexer

public struct ReturnStatement: Node {
  public let token: Token
  public let value: Expression?

  func tokenLiteral() -> String {
    return token.literal
  }
}
