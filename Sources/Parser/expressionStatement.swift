import Lexer

public struct ExpressionStatement: Statement {
  // The first token of the expression
  public let token: Token

  // The expression that this statement represents
  public let expression: ASTExpression

  public func tokenLiteral() -> String {
    return token.literal
  }
}

extension ExpressionStatement: CustomStringConvertible {
  public var description: String {
    return "\(expression)"
  }
}
