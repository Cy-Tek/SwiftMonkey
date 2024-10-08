import Lexer

public struct ReturnStatement: Statement {
  public let token: Token
  public let value: ASTExpression

  public func tokenLiteral() -> String {
    return token.literal
  }
}

extension ReturnStatement: CustomStringConvertible {
  public var description: String {
    return "\(tokenLiteral()) \(value);"
  }
}
