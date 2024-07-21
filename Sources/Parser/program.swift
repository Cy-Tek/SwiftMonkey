public class Program: Node {
  public var statements: [Statement]

  init() {
    statements = []
  }

  func tokenLiteral() -> String {
    return statements.first?.tokenLiteral() ?? ""
  }
}
