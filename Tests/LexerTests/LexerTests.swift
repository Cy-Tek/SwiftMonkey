import XCTest

@testable import Lexer

final class LexerTests: XCTestCase {
  func testNextToken() {
    let input = """
      let five = 5;
      let ten = 10;

      let add = fn(x, y) {
        x + y;
      };

      let result = add(five, ten);
      !-/*5;
      5 < 10 > 5;

      if (5 < 10) {
        return true;
      } else {
        return false;
      }

      10 == 10;
      10 != 9;
      """

    let expectedTokens: [(TokenType, String)] = [
      (.let, "let"),
      (.ident, "five"),
      (.assign, "="),
      (.int, "5"),
      (.semicolon, ";"),

      (.let, "let"),
      (.ident, "ten"),
      (.assign, "="),
      (.int, "10"),
      (.semicolon, ";"),

      (.let, "let"),
      (.ident, "add"),
      (.assign, "="),
      (.function, "fn"),
      (.l_paren, "("),

      (.ident, "x"),
      (.comma, ","),
      (.ident, "y"),
      (.r_paren, ")"),
      (.l_brace, "{"),

      (.ident, "x"),
      (.plus, "+"),
      (.ident, "y"),
      (.semicolon, ";"),

      (.r_brace, "}"),
      (.semicolon, ";"),

      (.let, "let"),
      (.ident, "result"),
      (.assign, "="),
      (.ident, "add"),
      (.l_paren, "("),
      (.ident, "five"),
      (.comma, ","),
      (.ident, "ten"),
      (.r_paren, ")"),
      (.semicolon, ";"),

      (.bang, "!"),
      (.minus, "-"),
      (.slash, "/"),
      (.asterisk, "*"),
      (.int, "5"),
      (.semicolon, ";"),

      (.int, "5"),
      (.lt, "<"),
      (.int, "10"),
      (.gt, ">"),
      (.int, "5"),
      (.semicolon, ";"),

      (.if, "if"),
      (.l_paren, "("),
      (.int, "5"),
      (.lt, "<"),
      (.int, "10"),
      (.r_paren, ")"),
      (.l_brace, "{"),

      (.return, "return"),
      (.true, "true"),
      (.semicolon, ";"),

      (.r_brace, "}"),
      (.else, "else"),
      (.l_brace, "{"),

      (.return, "return"),
      (.false, "false"),
      (.semicolon, ";"),

      (.r_brace, "}"),

      (.int, "10"),
      (.equal, "=="),
      (.int, "10"),
      (.semicolon, ";"),

      (.int, "10"),
      (.not_equal, "!="),
      (.int, "9"),
      (.semicolon, ";"),

      (.eof, "\0"),
    ]

    let lexer = Lexer(input: input)

    for (expectedType, expectedLiteral) in expectedTokens {
      let token = lexer.nextToken()
      XCTAssertEqual(token.type, expectedType)
      XCTAssertEqual(token.literal, expectedLiteral)
    }
  }
}
