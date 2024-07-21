import Lexer
import XCTest

@testable import Parser

final class ASTTests: XCTestCase {
  func testStringConversion() {
    let expected = "let myVar = anotherVar;"
    let program = Program()
    program.statements = [
      .letStatement(
        LetStatement(
          token: Token(.let, "let"),
          name: Identifier(token: Token(.ident, "myVar"), value: "myVar"),
          value: .identifier(Identifier(token: Token(.ident, "anotherVar"), value: "anotherVar"))))
    ]

    XCTAssertEqual(program.description, expected)
  }
}
