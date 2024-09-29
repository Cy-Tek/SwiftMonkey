import Lexer

public struct LetStatement: Statement {
  public let token: Token
  public let name: Identifier
  public let value: ASTExpression

  public func tokenLiteral() -> String {
    return token.literal
  }
}

extension LetStatement: CustomStringConvertible {
  public var description: String {
    return "\(tokenLiteral()) \(name) = \(value);"
  }
}
