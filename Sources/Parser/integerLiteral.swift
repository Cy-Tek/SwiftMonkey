import Lexer

public class IntegerLiteral: Node {
  public var token: Token
  public var value: Int

  public init(token: Token, value: Int) {
    self.token = token
    self.value = value
  }

  public func tokenLiteral() -> String {
    return self.token.literal
  }
}

extension IntegerLiteral: CustomStringConvertible {
  public var description: String {
    return self.token.literal
  }
}
