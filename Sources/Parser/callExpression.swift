import Lexer

public struct CallExpression: ASTExpression {
  public let token: Token
  public let function: ASTExpression
  private(set) public var arguments: [ASTExpression]

  public init(token: Token, fn: ASTExpression) throws {
    self.token = token
    self.arguments = []

    switch fn {
    case is Identifier: self.function = fn
    case is FunctionLiteral: self.function = fn
    default:
      throw ParsingError.unexpectedExpressionType(expected: "fn or identifier", found: "\(fn)")
    }
  }

  public mutating func addArg(_ arg: ASTExpression) {
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
