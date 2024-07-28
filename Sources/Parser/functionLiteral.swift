import Lexer

public struct FunctionLiteral: Node {
  public let token: Token
  private(set) public var params: [Identifier]
  public let body: BlockStatement?

  public func tokenLiteral() -> String {
    return token.literal
  }

  public mutating func addParam(param: Identifier) {
    params.append(param)
  }
}

extension FunctionLiteral: CustomStringConvertible {
  public var description: String {
    var msg = "\(tokenLiteral())("

    msg += params.map { $0.description }.joined(separator: ", ")
    msg += ") { "

    if let body = self.body {
      msg += "\(body.description) "
    }

    msg += "}"

    return msg
  }
}
