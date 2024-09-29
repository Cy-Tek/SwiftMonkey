import Lexer

public struct IfExpression: ASTExpression {
  public let token: Token
  public let condition: ASTExpression
  public let consequence: BlockStatement
  public let alternative: BlockStatement?

  public init(
    token: Token, condition: ASTExpression, consequence: BlockStatement, alternative: BlockStatement?
  ) {
    self.token = token
    self.condition = condition
    self.consequence = consequence
    self.alternative = alternative
  }

  public func tokenLiteral() -> String {
    return token.literal
  }
}

extension IfExpression: CustomStringConvertible {
  public var description: String {
    var out = "if \(condition) \(consequence)"

    if let alt = alternative {
      out += "else \(alt)"
    }

    return out
  }
}
