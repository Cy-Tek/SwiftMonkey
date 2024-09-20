public protocol Object {
  func inspect() -> String
}

public struct Integer: Object {
  public let value: Int64

  public init(_ value: Int64) {
    self.value = value
  }

  public init(_ value: Int) {
    self.value = Int64(value)
  }

  public func inspect() -> String {
    return value.description
  }
}

public struct Boolean: Object {
  public let value: Bool

  public init(_ value: Bool) {
    self.value = value
  }

  public func inspect() -> String {
    return value.description
  }
}

public struct Null: Object {
  public init() {}

  public func inspect() -> String {
    return "null"
  }
}
