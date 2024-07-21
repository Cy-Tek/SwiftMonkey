import Lexer

public struct ReturnStatement: Node {
  public let token: Token
  public let value: Expression?

  public func tokenLiteral() -> String {
    return token.literal
  }
}

extension ReturnStatement: CustomStringConvertible {
  public var description: String {
    var desc = "\(tokenLiteral())"
    if let value = value {
      desc += " \(value)"
    }

    desc += ";"
    return desc
  }
}
