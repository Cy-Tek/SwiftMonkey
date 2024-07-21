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

func testParserErrors(_ parser: Parser) -> Bool {
  if parser.errors.isEmpty {
    return true
  }

  for error in parser.errors {
    XCTFail("Parser error: \(error)")
  }

  XCTFail("Parser has \(parser.errors.count) errors")
  return false
}

final class ParserTests: XCTestCase {
  func testLetStatements() {
    let input = """
      let x = 5;
      let y = 10;
      let foobar = 838383;
      """

    let parser = Parser(input: input)
    let program = parser.parseProgram()
    guard testParserErrors(parser) else { return }

    XCTAssertEqual(program.statements.count, 3)

    let tests: [String] = [
      "x", "y", "foobar",
    ]

    for (stmt, expectedIdentifier) in zip(program.statements, tests) {
      guard testLetStatement(statement: stmt, name: expectedIdentifier) else {
        return
      }
    }
  }
}
