// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftMonkey",
  products: [
    .library(name: "Lexer", targets: ["Lexer"]),
    .library(name: "Parser", targets: ["Parser"]),
    .executable(name: "monkey", targets: ["MonkeyInterpreter"]),
  ],
  targets: [
    .target(name: "Lexer", dependencies: []),
    .target(name: "Parser", dependencies: ["Lexer"]),
    .executableTarget(name: "MonkeyInterpreter", dependencies: ["Lexer"]),
    .testTarget(name: "LexerTests", dependencies: ["Lexer"]),
    .testTarget(name: "ParserTests", dependencies: ["Parser"]),
  ]
)
