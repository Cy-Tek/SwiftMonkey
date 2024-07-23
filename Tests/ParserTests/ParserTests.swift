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

      XCTAssert(
        testInfixExpression(
          expression: expression,
          left: test.leftValue,
          op: test.op,
          right: test.rightValue
        )
      )
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

func testIdentifier(expression: Expression, value: String) -> Bool {
  guard case .identifier(let identifier) = expression else {
    XCTFail("Expression was not an identifier")
    return false
  }

  guard identifier.value == value else {
    XCTFail("Identifier value was \(identifier.value), but expected \(value)")
    return false
  }

  guard identifier.tokenLiteral() == value else {
    XCTFail("Identifier token literal was \(identifier.tokenLiteral()), but expected \(value)")
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

func testLiteralExpression(expression: Expression, expected: Any) -> Bool {
  switch expected {
  case let value as Int:
    return testIntegerLiteral(expression: expression, value: value)
  case let value as String:
    return testIdentifier(expression: expression, value: value)
  default:
    XCTFail("Type of expression not handled. Expected Int or String, but got \(type(of: expected))")
    return false
  }
}

func testInfixExpression(
  expression: Expression,
  left: Any,
  op: String,
  right: Any
) -> Bool {
  guard case .infix(let infixExpr) = expression else {
    XCTFail("Expression was not an infix expression")
    return false
  }

  // Left expression testing

  guard let leftExpression = infixExpr.left else {
    XCTFail("Left expression is nil")
    return false
  }

  guard testLiteralExpression(expression: leftExpression, expected: left) else {
    return false
  }

  // Operator testing

  XCTAssertEqual(infixExpr.op, op)

  // Right expression testing

  guard let rightExpression = infixExpr.right else {
    XCTFail("Right expression is nil")
    return false
  }

  guard testLiteralExpression(expression: rightExpression, expected: right) else {
    return false
  }

  return true
}
