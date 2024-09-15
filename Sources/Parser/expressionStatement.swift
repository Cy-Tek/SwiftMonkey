import Lexer

public struct ExpressionStatement: Node {
  // The first token of the expression
  public let token: Token

  // The expression that this statement represents
  public let expression: Expression

  public func tokenLiteral() -> String {
    return token.literal
  }
}

extension ExpressionStatement: CustomStringConvertible {
  public var description: String {
    return "\(expression)"
  }
}
