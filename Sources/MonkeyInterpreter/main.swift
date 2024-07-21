import Foundation
import Lexer

let prompt = ">> "

func startREPL() {
  print("Welcome to the Monkey programming language!")
  print("Feel free to type in commands")
  print(prompt, terminator: "")

  while let line = readLine() {
    guard line != "quit;" else {
      break
    }

    let lexer = Lexer(input: line)
    var token = lexer.nextToken()
    while token.type != .eof {
      print(token)
      token = lexer.nextToken()
    }

    print(prompt, terminator: "")
  }
}

startREPL()
