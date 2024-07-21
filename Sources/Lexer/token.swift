public enum TokenType {
  case illegal
  case eof

  // Identifiers + literals
  case ident
  case int

  // Operators
  case assign
  case bang
  case plus
  case minus
  case asterisk
  case slash

  case lt
  case gt
  case equal
  case not_equal

  // Delimiters
  case comma
  case semicolon

  case l_paren
  case r_paren
  case l_brace
  case r_brace

  // Keywords
  case function
  case `let`
  case `true`
  case `false`
  case `return`
  case `if`
  case `else`
}

public struct Token {
  public let type: TokenType
  public let literal: String

  public init() {
    type = .illegal
    literal = ""
  }

  public init(_ type: TokenType, _ literal: String) {
    self.type = type
    self.literal = literal
  }

  public init(_ type: TokenType, _ literal: Character) {
    self.type = type
    self.literal = String(literal)
  }
}
