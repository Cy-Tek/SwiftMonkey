import XCTest

@testable import Parser

func testLetStatement(statement: Statement, name: String) -> Bool {
  XCTAssertEqual(statement.tokenLiteral(), "let")

  guard case .letStatement(let letStmt) = statement else {
    XCTFail("Statement was not a LetStatement.")
    return false
  }

  XCTAssertEqual(letStmt.name.value, name)
  XCTAssertEqual(letStmt.name.tokenLiteral(), name)
  return true
}

final class ParserTests: XCTestCase {
  func testLetStatements() {
    let input = """
      let x = 5;
      let y = 10;
      let foobar = 838383;
      """

    let parser = Parser(input: input)
    guard let program = try? parser.parseProgram() else {
      XCTFail("Failed to find a valid program.")
      return
    }

    XCTAssertEqual(program.statements.count, 3)

    let tests: [String] = [
      "x", "y", "foobar",
    ]

    for (stmt, expectedIdentifier) in zip(program.statements, tests) {
      if !testLetStatement(statement: stmt, name: expectedIdentifier) {
        return
      }
    }
  }
}
