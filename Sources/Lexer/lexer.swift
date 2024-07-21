private enum Keywords {
  private static let keywords: [String: TokenType] = [
    "fn": .function,
    "let": .let,
    "true": .true,
    "false": .false,
    "return": .return,
    "if": .if,
    "else": .else,
  ]

  public static func lookup(for literal: String) -> TokenType {
    return keywords[literal] ?? .ident
  }
}

public class Lexer {
  private let input: String
  private let indices: [String.Index]

  private var position = 0
  private var readPosition = 0
  private var ch: Character = "\0"

  public init(input: String) {
    self.input = input
    indices = Array(input.indices)

    readChar()
  }

  public func nextToken() -> Token {
    let token: Token
    skipWhitespace()

    switch ch {
    case "=":
      if peekChar() == "=" {
        readChar()
        token = Token(.equal, "==")
      } else {
        token = Token(.assign, ch)
      }
    case "!":
      if peekChar() == "=" {
        readChar()
        token = Token(.not_equal, "!=")
      } else {
        token = Token(.bang, "!")
      }
    case ";": token = Token(.semicolon, ch)
    case "(": token = Token(.l_paren, ch)
    case ")": token = Token(.r_paren, ch)
    case "{": token = Token(.l_brace, ch)
    case "}": token = Token(.r_brace, ch)
    case ",": token = Token(.comma, ch)
    case "+": token = Token(.plus, ch)
    case "-": token = Token(.minus, ch)
    case "*": token = Token(.asterisk, ch)
    case "/": token = Token(.slash, ch)
    case "<": token = Token(.lt, ch)
    case ">": token = Token(.gt, ch)
    case "a"..."z", "A"..."Z": return readIdentifier()
    case "0"..."9": return readNumber()
    case "\0": token = Token(.eof, ch)
    default: token = Token(.illegal, "")
    }

    readChar()
    return token
  }

  private func skipWhitespace() {
    while ch.isWhitespace {
      readChar()
    }
  }

  private func readChar() {
    ch = currentChar() ?? "\0"
    position = readPosition
    readPosition += 1
  }

  private func peekChar() -> Character {
    guard readPosition < input.count else {
      return "\0"
    }

    return input[indices[readPosition]]
  }

  private func readIdentifier() -> Token {
    let start = indices[position]
    while ch.isLetter {
      readChar()
    }

    let end = indices[position]
    let literal = String(input[start..<end])
    let type = Keywords.lookup(for: literal)

    return Token(type, literal)
  }

  private func readNumber() -> Token {
    let start = indices[position]
    while ch.isNumber {
      readChar()
    }

    let end = indices[position]
    let literal = String(input[start..<end])

    return Token(.int, literal)
  }

  @inline(__always)
  private func currentChar() -> Character? {
    guard readPosition < input.count else {
      return nil
    }

    return input[indices[readPosition]]
  }
}
