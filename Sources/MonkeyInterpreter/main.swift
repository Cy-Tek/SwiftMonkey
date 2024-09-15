import Evaluator
import Foundation
import Parser

let prompt = ">> "

func startREPL() throws {
  print("Welcome to the Monkey programming language!")
  print("Feel free to type in commands")

  while true {
    // Print the prompt before reading input
    print(prompt, terminator: "")

    guard let line = readLine(), line != "quit;" else {
      break
    }

    let parser = Parser(input: line)
    let program = parser.parseProgram()

    if parser.errors.count > 0 {
      for err in parser.errors {
        print("Parser Error: \(err)")
      }
      continue
    }

    guard let evaluated = try? eval(node: program) else {
      continue
    }

    print("\(evaluated.inspect())")
  }
}

try startREPL()
