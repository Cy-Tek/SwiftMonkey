import XCTest

@testable import Parser

final class ParserTests: XCTestCase {
  func testLetStatements() {
    let tests: [(input: String, expectedIdentifier: String, expectedValue: Any)] = [
      ("let x = 5;", "x", 5),
      ("let y = true;", "y", true),
      ("let foobar = y;", "foobar", "y"),
    ]

    for test in tests {
      let parser = Parser(input: test.input)
      let program = parser.parseProgram()
      guard testParserErrors(parser) else { return }

      XCTAssertEqual(program.statements.count, 1)

      guard let stmt = program.statements.first else {
        XCTFail("Expected a valid statment to be found")
        return
      }

      guard
        testLetStatement(statement: stmt, name: test.expectedIdentifier, value: test.expectedValue)
      else {
        return
      }
    }
  }

  func testReturnStatements() {
    let input = """
      return 50;
      return true;
      return y;
      """

    let tests: [Any] = [
      50,
      true,
      "y",
    ]

    let parser = Parser(input: input)
    let program = parser.parseProgram()
    guard testParserErrors(parser) else { return }

    XCTAssertEqual(program.statements.count, 3)

    for (i, stmt) in program.statements.enumerated() {
      guard let returnStmt = stmt as? ReturnStatement else {
        XCTFail("Statement was not a return statement. Received literal \(stmt.tokenLiteral())")
        return
      }

      XCTAssertEqual(returnStmt.tokenLiteral(), "return")

      guard testLiteralExpression(expression: returnStmt.value, expected: tests[i]) else {
        return
      }
    }
  }

  func testIdentifierExpression() {
    let input = "foobar;"
    let parser = Parser(input: input)
    let program = parser.parseProgram()
    guard testParserErrors(parser) else { return }

    XCTAssertEqual(program.statements.count, 1)

    guard let expressionStmt = program.statements.first as? ExpressionStatement else {
      XCTFail("Statement was not an expression statement.")
      return
    }

    guard let identifier = expressionStmt.expression as? Identifier else {
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

    guard let expressionStmt = program.statements.first as? ExpressionStatement else {
      XCTFail("Statement was not an expression statement")
      return
    }

    let _ = testIntegerLiteral(expression: expressionStmt.expression, value: 5)
  }

  func testParsingPrefixExpressions() {
    let prefixTests: [(input: String, expectedOp: String, expectedValue: Any)] = [
      ("!5;", "!", 5),
      ("-15;", "-", 15),
      ("!true;", "!", true),
      ("!false;", "!", false),
    ]

    for test in prefixTests {
      let parser = Parser(input: test.input)
      let program = parser.parseProgram()
      guard testParserErrors(parser) else { return }

      XCTAssertEqual(program.statements.count, 1)

      guard let expressionStmt = program.statements.first as? ExpressionStatement else {
        XCTFail("Statement was not an expression statement")
        return
      }

      guard let prefixExpr = expressionStmt.expression as? PrefixExpression else {
        XCTFail("Expression was not a prefix expression")
        return
      }

      XCTAssertEqual(prefixExpr.op, test.expectedOp)
      guard testLiteralExpression(expression: prefixExpr.right!, expected: test.expectedValue)
      else {
        return
      }
    }
  }

  func testParsingInfixExpressions() {
    let infixTests: [(input: String, leftValue: Any, op: String, rightValue: Any)] = [
      ("5 + 5;", 5, "+", 5),
      ("5 - 5;", 5, "-", 5),
      ("5 * 5;", 5, "*", 5),
      ("5 / 5;", 5, "/", 5),
      ("5 > 5;", 5, ">", 5),
      ("5 < 5;", 5, "<", 5),
      ("5 == 5;", 5, "==", 5),
      ("5 != 5;", 5, "!=", 5),
      ("true == true;", true, "==", true),
      ("true != false;", true, "!=", false),
      ("false == false;", false, "==", false),
    ]

    for test in infixTests {
      let parser = Parser(input: test.input)
      let program = parser.parseProgram()
      guard testParserErrors(parser) else { return }

      XCTAssertEqual(program.statements.count, 1)

      guard let expressionStmt = program.statements.first as? ExpressionStatement else {
        XCTFail("Statement was not an expression statement")
        return
      }

      guard
        testInfixExpression(
          expression: expressionStmt.expression,
          left: test.leftValue,
          op: test.op,
          right: test.rightValue
        )
      else { return }
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
      (
        "1 + (2 + 3) + 4",
        "((1 + (2 + 3)) + 4)"
      ),
      (
        "(5 + 5) * 2",
        "((5 + 5) * 2)"
      ),
      (
        "2 / (5 + 5)",
        "(2 / (5 + 5))"
      ),
      (
        "-(5 + 5)",
        "(-(5 + 5))"
      ),
      (
        "!(true == true)",
        "(!(true == true))"
      ),
      (
        "a + add(b * c) + d",
        "((a + add((b * c))) + d)"
      ),
      (
        "add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))",
        "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"
      ),
      (
        "add(a + b + c * d / f + g)",
        "add((((a + b) + ((c * d) / f)) + g))"
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

  func testIfExpression() {
    let input = "if (x < y) { x }"
    let parser = Parser(input: input)
    let program = parser.parseProgram()
    guard testParserErrors(parser) else { return }

    XCTAssertEqual(program.statements.count, 1)

    guard let expressionStmt = program.statements.first as? ExpressionStatement else {
      XCTFail("Statement was not an expression statement")
      return
    }

    guard let ifExpr = expressionStmt.expression as? IfExpression else {
      XCTFail("Expression was not an if expression")
      return
    }

    XCTAssertEqual(ifExpr.tokenLiteral(), "if")

    guard testInfixExpression(expression: ifExpr.condition, left: "x", op: "<", right: "y") else {
      return
    }

    XCTAssertEqual(ifExpr.consequence.statements.count, 1)

    guard let consequenceStmt = ifExpr.consequence.statements.first as? ExpressionStatement
    else {
      XCTFail("Consequence statement was not an expression statement")
      return
    }

    guard testIdentifier(expression: consequenceStmt.expression, value: "x") else {
      return
    }

    XCTAssertNil(ifExpr.alternative)
  }

  func testFunctionLiteral() {
    let input = "fn(x, y) { x + y; }"
    let parser = Parser(input: input)
    let program = parser.parseProgram()
    guard testParserErrors(parser) else { return }

    XCTAssertEqual(program.statements.count, 1)

    guard let expressionStmt = program.statements.first as? ExpressionStatement else {
      XCTFail("Statement was not an expression statement")
      return
    }

    guard let fnExpr = expressionStmt.expression as? FunctionLiteral else {
      XCTFail("Expression was not an fn expression")
      return
    }

    guard fnExpr.params.count == 2 else {
      XCTFail("Expected 2 parameters, but found \(fnExpr.params.count)")
      return
    }

    let _ = testLiteralExpression(expression: fnExpr.params[0], expected: "x")
    let _ = testLiteralExpression(expression: fnExpr.params[1], expected: "y")

    guard let fnBody = fnExpr.body else {
      XCTFail("Expected to find a function body")
      return
    }

    guard fnBody.statements.count == 1 else {
      XCTFail(
        "Expected 1 statement in the function body, but received \(fnBody.statements.count)")
      return
    }

    guard let bodyStmt = fnBody.statements[0] as? ExpressionStatement else {
      XCTFail("Expected to get an expression statement")
      return
    }

    let _ = testInfixExpression(expression: bodyStmt.expression, left: "x", op: "+", right: "y")
  }

  func testFunctionParameterParsing() {
    let tests: [(input: String, expectedParams: [String])] = [
      ("fn() {};", []),
      ("fn(x) {};", ["x"]),
      ("fn(x, y, z) {};", ["x", "y", "z"]),
    ]

    for test in tests {
      let parser = Parser(input: test.input)
      let program = parser.parseProgram()
      guard testParserErrors(parser) else { return }

      XCTAssertEqual(program.statements.count, 1)

      guard let expressionStmt = program.statements.first as? ExpressionStatement else {
        XCTFail("Expression was not an expression statement")
        return
      }

      guard let function = expressionStmt.expression as? FunctionLiteral else {
        XCTFail("Expected expression statement to be a function literal")
        return
      }

      guard function.params.count == test.expectedParams.count else {
        XCTFail(
          "Expected \(test.expectedParams.count) params, but received \(function.params.count)")
        return
      }

      for (i, param) in test.expectedParams.enumerated() {
        guard testLiteralExpression(expression: function.params[i], expected: param) else {
          return
        }
      }
    }
  }

  func testCallExpressions() {
    let input = "add(1, 2 * 3, 4 + 5);"
    let parser = Parser(input: input)
    let program = parser.parseProgram()
    guard testParserErrors(parser) else { return }

    XCTAssertEqual(program.statements.count, 1)

    guard let expressionStmt = program.statements.first as? ExpressionStatement else {
      XCTFail(
        "Expected an expression statement but found \(program.statements.first?.description ?? "nil")"
      )
      return
    }

    guard let callExpr = expressionStmt.expression as? CallExpression else {
      XCTFail(
        "Expected a call expression but found \(expressionStmt.expression)")
      return
    }

    let _ = testLiteralExpression(expression: callExpr.arguments[0], expected: 1)
    let _ = testInfixExpression(expression: callExpr.arguments[1], left: 2, op: "*", right: 3)
    let _ = testInfixExpression(expression: callExpr.arguments[2], left: 4, op: "+", right: 5)
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

func testLetStatement(statement: Statement, name: String, value: Any) -> Bool {
  XCTAssertEqual(statement.tokenLiteral(), "let")

  guard let letStmt = statement as? LetStatement else {
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

  guard testLiteralExpression(expression: letStmt.value, expected: value) else {
    return false
  }

  return true
}

func testIdentifier(expression: Expression, value: String) -> Bool {
  guard let identifier = expression as? Identifier else {
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
  guard let literal = expression as? IntegerLiteral else {
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

func testBooleanLiteral(expression: Expression, expected: Bool) -> Bool {
  guard let boolExpr = expression as? BooleanLiteral else {
    XCTFail("Expected a BooleanLiteral expression")
    return false
  }

  guard boolExpr.value == expected else {
    XCTFail("Expected \(expected), but found \(boolExpr.value)")
    return false
  }

  guard boolExpr.tokenLiteral() == String(expected) else {
    XCTFail("Expected token literal to be \(expected), but found \(boolExpr.tokenLiteral())")
    return false
  }

  return true
}

func testLiteralExpression(expression: Expression, expected: Any) -> Bool {
  switch expected {
  case let value as Int:
    return testIntegerLiteral(expression: expression, value: value)
  case let value as Bool:
    return testBooleanLiteral(expression: expression, expected: value)
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
  guard let infixExpr = expression as? InfixExpression else {
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
