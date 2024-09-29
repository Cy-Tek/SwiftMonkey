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
  case let ie as InfixExpression:
    guard let leftExpr = ie.left else {
      throw EvaluationError.evaluationFailed
    }

    guard let rightExpr = ie.right else {
      throw EvaluationError.evaluationFailed
    }

    let leftValue = try eval(node: leftExpr)
    let rightValue = try eval(node: rightExpr)

    return try evalInfixExpression(left: leftValue, op: ie.op, right: rightValue)
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
  case "-":
    return try evalNegationOperator(right: right)
  default:
    throw EvaluationError.unimplemented
  }
}

func evalInfixExpression(left: Object, op: String, right: Object) throws -> Object {
  switch op {
  case "-":
    return try evalMinusOperator(left: left, right: right)
  case "+":
    return try evalPlusOperator(left: left, right: right)
  case "/":
    return try evalSlashOperator(left: left, right: right)
  case "*":
    return try evalAsteriskOperator(left: left, right: right)
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

func evalNegationOperator(right: Object) throws -> Object {
  guard let expr = right as? Integer else {
    return Null()
  }

  return Integer(-expr.value)
}

func evalPlusOperator(left: Object, right: Object) throws -> Object {
  guard let leftInt = left as? Integer, let rightInt = right as? Integer else {
    throw EvaluationError.evaluationFailed
  }

  return Integer(leftInt.value + rightInt.value)
}

func evalMinusOperator(left: Object, right: Object) throws -> Object {
  guard let leftInt = left as? Integer, let rightInt = right as? Integer else {
    throw EvaluationError.evaluationFailed
  }

  return Integer(leftInt.value - rightInt.value)
}

func evalAsteriskOperator(left: Object, right: Object) throws -> Object {
  guard let leftInt = left as? Integer, let rightInt = right as? Integer else {
    throw EvaluationError.evaluationFailed
  }

  return Integer(leftInt.value * rightInt.value)
}

func evalSlashOperator(left: Object, right: Object) throws -> Object {
  guard let leftInt = left as? Integer, let rightInt = right as? Integer else {
    throw EvaluationError.evaluationFailed
  }

  return Integer(leftInt.value / rightInt.value)
}
