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

    guard let expression = expressionStmt.expression else {
      XCTFail("Found nil expression, but expected an integer literal")
      return
    }

    let _ = testIntegerLiteral(expression: expression, value: 5)
  }

  func testParsingPrefixExpressions() {
    let prefixTests: [(input: String, expectedOp: String, expectedValue: Int)] = [
      ("!5;", "!", 5),
      ("-15;", "-", 15),
    ]

    for test in prefixTests {
      let parser = Parser(input: test.input)
      let program = parser.parseProgram()
      guard testParserErrors(parser) else { return }

      XCTAssertEqual(program.statements.count, 1)

      guard case .expressionStatement(let expressionStmt) = program.statements.first else {
        XCTFail("Statement was not an expression statement")
        return
      }

      guard let expression = expressionStmt.expression else {
        XCTFail("Found nil expression, but expected a prefix expression")
        return
      }

      guard case .prefix(let prefixExpr) = expression else {
        XCTFail("Expression was not a prefix expression")
        return
      }

      XCTAssertEqual(prefixExpr.op, test.expectedOp)
      guard testIntegerLiteral(expression: prefixExpr.right!, value: test.expectedValue) else {
        return
      }
    }
  }

  func testParsingInfixExpressions() {
    let infixTests: [(input: String, leftValue: Int, op: String, rightValue: Int)] = [
      ("5 + 5;", 5, "+", 5),
      ("5 - 5;", 5, "-", 5),
      ("5 * 5;", 5, "*", 5),
      ("5 / 5;", 5, "/", 5),
      ("5 > 5;", 5, ">", 5),
      ("5 < 5;", 5, "<", 5),
      ("5 == 5;", 5, "==", 5),
      ("5 != 5;", 5, "!=", 5),
    ]

    for test in infixTests {
      let parser = Parser(input: test.input)
      let program = parser.parseProgram()
      guard testParserErrors(parser) else { return }

      XCTAssertEqual(program.statements.count, 1)

      guard case .expressionStatement(let expressionStmt) = program.statements.first else {
        XCTFail("Statement was not an expression statement")
        return
      }

      guard let expression = expressionStmt.expression else {
        XCTFail("Found nil expression, but expected an infix expression")
        return
      }

      guard case .infix(let infixExpr) = expression else {
        XCTFail("Expression was not an infix expression")
        return
      }

      if let left = infixExpr.left {
        guard testIntegerLiteral(expression: left, value: test.leftValue) else {
          return
        }
      }

      XCTAssertEqual(infixExpr.op, test.op)

      if let right = infixExpr.right {
        guard testIntegerLiteral(expression: right, value: test.rightValue) else {
          return
        }
      }
    }
  }

  func testOperatorPrecedenceParsing() {
    let tests: [(input: String, expected: String)] = [
      (
        "-a * b",
        "((-a) * b)"
      ),
      (
        "!-a",
        "(!(-a))"
      ),
      (
        "a + b + c",
        "((a + b) + c)"
      ),
      (
        "a + b - c",
        "((a + b) - c)"
      ),
      (
        "a * b * c",
        "((a * b) * c)"
      ),
      (
        "a * b / c",
        "((a * b) / c)"
      ),
      (
        "a + b / c",
        "(a + (b / c))"
      ),
      (
        "a + b * c + d / e - f",
        "(((a + (b * c)) + (d / e)) - f)"
      ),
      (
        "3 + 4; -5 * 5",
        "(3 + 4)((-5) * 5)"
      ),
      (
        "5 > 4 == 3 < 4",
        "((5 > 4) == (3 < 4))"
      ),
      (
        "5 < 4 != 3 > 4",
        "((5 < 4) != (3 > 4))"
      ),
      (
        "3 + 4 * 5 == 3 * 1 + 4 * 5",
        "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"
      ),
    ]

    for test in tests {
      let parser = Parser(input: test.input)
      let program = parser.parseProgram()
      guard testParserErrors(parser) else { return }

      let actual = program.description
      XCTAssertEqual(test.expected, actual)
    }
  }
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

func testLetStatement(statement: Statement, name: String) -> Bool {
  XCTAssertEqual(statement.tokenLiteral(), "let")

  guard case .letStatement(let letStmt) = statement else {
    XCTFail("Statement was not a LetStatement.")
    return false
  }

  guard letStmt.name.value == name else {
    XCTFail("Let statement name was \(letStmt.name.value), but expected \(name)")
    return false
  }

  guard letStmt.name.tokenLiteral() == name else {
    XCTFail(
      "Let statement name token literal was \(letStmt.name.tokenLiteral()), but expected \(name)")
    return false
  }

  return true
}

func testIntegerLiteral(expression: Expression, value: Int) -> Bool {
  guard case .integer(let literal) = expression else {
    XCTFail("Expression was not an integer literal")
    return false
  }

  guard literal.value == value else {
    XCTFail("Integer literal value was \(literal.value), but expected \(value)")
    return false
  }

  guard literal.tokenLiteral() == String(value) else {
    XCTFail("Integer literal token literal was \(literal.tokenLiteral()), but expected \(value)")
    return false
  }

  return true
}
