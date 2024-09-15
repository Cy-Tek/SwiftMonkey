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
      try testIntegerObject(obj: evaluated, expected: test.expected)
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
