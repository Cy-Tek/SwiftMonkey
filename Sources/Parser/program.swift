public class Program: Node {
  public var statements: [Statement]

  init() {
    statements = []
  }

  public func tokenLiteral() -> String {
    return statements.first?.tokenLiteral() ?? ""
  }
}
