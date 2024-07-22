public class Program: Node {
  public var statements: [Statement]

  init() {
    statements = []
  }

  public func tokenLiteral() -> String {
    return statements.first?.tokenLiteral() ?? ""
  }
}

extension Program: CustomStringConvertible {
  public var description: String {
    return statements.map { $0.description }.joined()
  }
}
