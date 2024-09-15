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
  case let pe as PrefixExpression:
    guard let expr = pe.right else {
      throw EvaluationError.evaluationFailed
    }

    let right = try eval(node: expr)
    return try evalPrefixExpression(op: pe.op, right: right)
  case let il as IntegerLiteral:
    return Integer(il.value)
  case let bl as BooleanLiteral:
    return Boolean(bl.value)

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

func evalPrefixExpression(op: String, right: Object) throws -> Object {
  switch op {
  case "!":
    return try evalBangOperator(right: right)
  default:
    throw EvaluationError.unimplemented
  }
}

func evalBangOperator(right: Object) throws -> Object {
  switch right {
  case let right as Boolean:
    return Boolean(!right.value)
  case let right as Integer:
    return if right.value == 0 { Boolean(true) } else { Boolean(false) }
  case is Null:
    return Boolean(true)
  default:
    return Boolean(false)
  }
}
