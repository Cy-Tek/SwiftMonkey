import Lexer

public struct InfixExpression: Node {
  public let token: Token
  public let left: Expression?
  public let op: String
  public let right: Expression?

  public init(token: Token, left: Expression?, op: String, right: Expression?) {
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
