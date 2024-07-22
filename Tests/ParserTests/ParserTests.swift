import XCTest

@testable import Parser

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

  func testReturnStatements() {
    let input = """
      return 5;
      return 10;
      return 993322;
      """

    let parser = Parser(input: input)
    let program = parser.parseProgram()
    guard testParserErrors(parser) else { return }

    XCTAssertEqual(program.statements.count, 3)

    for stmt in program.statements {
      guard case .returnStatement(let returnStmt) = stmt else {
        XCTFail("Statement was not a return statement. Received literal \(stmt.tokenLiteral())")
        return
      }

      XCTAssertEqual(returnStmt.tokenLiteral(), "return")
    }
  }

  func testIdentifierExpression() {
    let input = "foobar;"
    let parser = Parser(input: input)
    let program = parser.parseProgram()
    guard testParserErrors(parser) else { return }

    XCTAssertEqual(program.statements.count, 1)

    guard case .expressionStatement(let expressionStmt) = program.statements.first else {
      XCTFail("Statement was not an expression statement.")
      return
    }

    guard case .identifier(let identifier) = expressionStmt.expression else {
      XCTFail("Expression was not an identifier.")
      return
    }

    XCTAssertEqual(identifier.value, "foobar")
    XCTAssertEqual(identifier.tokenLiteral(), "foobar")
  }

  func testIntegerLiteralExpression() {
    let input = "5;"
    let parser = Parser(input: input)
    let program = parser.parseProgram()
    guard testParserErrors(parser) else { return }

    XCTAssertEqual(program.statements.count, 1)

    guard case .expressionStatement(let expressionStmt) = program.statements.first else {
      XCTFail("Statement was not an expression statement")
      return
    }

    guard case .integer(let literal) = expressionStmt.expression else {
      XCTFail("Expression was not an integer literal")
      return
    }

    XCTAssertEqual(literal.value, 5)
    XCTAssertEqual(literal.tokenLiteral(), "5")
  }
}

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
