import Evaluator
import Object
import Parser
import XCTest

final class EvaluatorTests: XCTestCase {
  func testEvalInteger() throws {
    let tests: [(input: String, expected: Int64)] = [
      ("5", 5),
      ("10", 10),
    ]

    for test in tests {
      let evaluated = try testEval(test.input)
      let _ = try testIntegerObject(obj: evaluated, expected: test.expected)
    }
  }

  func testEvalBool() throws {
    let tests: [(input: String, expected: Bool)] = [
      ("true", true),
      ("false", false),
    ]

    for test in tests {
      let evaluated = try testEval(test.input)
      let _ = try testBoolObject(obj: evaluated, expected: test.expected)
    }
  }

  func testBangOperator() throws {
    let tests: [(input: String, expected: Bool)] = [
      ("!true", false),
      ("!false", true),
      ("!!true", true),
      ("!!false", false),

      // Truthy numbers except 0
      ("!5", false),
      ("!!5", true),
      ("!0", true),
      ("!!0", false),
    ]

    for test in tests {
      let evaluated = try testEval(test.input)
      let _ = try testBoolObject(obj: evaluated, expected: test.expected)
    }
  }
}

func testEval(_ input: String) throws -> Object {
  let parser = Parser(input: input)
  let program = parser.parseProgram()

  return try eval(node: program)
}

func testIntegerObject(obj: Object, expected: Int64) throws -> Bool {
  let result = obj as! Integer

  if result.value != expected {
    XCTFail("Expected value to equal \(expected), but received \(result.value)")
    return false
  }

  return true
}

func testBoolObject(obj: Object, expected: Bool) throws -> Bool {
  let result = obj as! Boolean

  if result.value != expected {
    XCTFail("Expected value to equal \(expected), but received \(result.value)")
    return false
  }

  return true
}
