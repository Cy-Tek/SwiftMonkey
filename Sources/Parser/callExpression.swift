import Lexer

public struct CallExpression: Node {
  public let token: Token
  public let function: Expression
  private(set) public var arguments: [Expression]

  public init(token: Token, fn: Expression) throws {
    self.token = token
    self.arguments = []

    switch fn {
    case .identifier: self.function = fn
    case .fn: self.function = fn
    default:
      throw ParsingError.unexpectedExpressionType(expected: "fn or identifier", found: "\(fn)")
    }
  }

  public mutating func addArg(_ arg: Expression) {
    arguments.append(arg)
  }

  public func tokenLiteral() -> String {
    return token.literal
  }
}

extension CallExpression: CustomStringConvertible {
  public var description: String {
    var msg = "\(function)("

    msg += arguments.map { $0.description }.joined(separator: ", ")
    msg += ")"

    return msg
  }
}
