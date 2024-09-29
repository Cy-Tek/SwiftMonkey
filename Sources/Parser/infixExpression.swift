import Lexer

public struct InfixExpression: ASTExpression {
  public let token: Token
  public let left: ASTExpression?
  public let op: String
  public let right: ASTExpression?

  public init(token: Token, left: ASTExpression?, op: String, right: ASTExpression?) {
    self.token = token
    self.left = left
    self.op = op
    self.right = right
  }

  public func tokenLiteral() -> String {
    return token.literal
  }
}

extension InfixExpression: CustomStringConvertible {
  public var description: String {
    var desc = "("

    if let left = self.left {
      desc += left.description
    }

    desc += " \(self.op) "

    if let right = self.right {
      desc += right.description
    }

    desc += ")"
    return desc
  }
}
