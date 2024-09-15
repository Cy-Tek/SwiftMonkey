import Object
import Parser

enum EvaluationError: Error {
  case unimplemented
  case evaluationFailed
}

public func eval(node: Node) throws -> Object {
  switch node {
  // Statements
  case let p as Program:
    return try evalStatements(stmts: p.statements)
  case let es as ExpressionStatement:
    return try eval(node: es.expression)

  // Expressions
  case let il as IntegerLiteral:
    return Integer(il.value)

  default:
    throw EvaluationError.unimplemented
  }
}

func evalStatements(stmts: [Statement]) throws -> Object {
  var result: Object? = nil

  for stmt in stmts {
    result = try eval(node: stmt)
  }

  guard let result else {
    throw EvaluationError.evaluationFailed
  }

  return result
}
