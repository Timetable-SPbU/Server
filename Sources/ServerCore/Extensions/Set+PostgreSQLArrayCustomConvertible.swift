//
//  Set+PostgreSQLArrayCustomConvertible.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 21/04/2018.
//

import FluentPostgreSQL

extension Set: PostgreSQLArrayType {

  /// See `PostgreSQLArrayCustomConvertible.postgreSQLDataArrayType`
  public static var postgreSQLDataArrayType: PostgreSQLDataType {
    fatalError("Multi-dimensional arrays are not yet supported.")
  }

  /// See `PostgreSQLDataCustomConvertible.postgreSQLDataType`
  public static var postgreSQLDataType: PostgreSQLDataType {
    return forceCast(Element.self).postgreSQLDataArrayType
  }

  /// See `PostgreSQLArrayCustomConvertible.PostgreSQLArrayElement`
  public typealias PostgreSQLArrayElement = Element

  /// See `PostgreSQLArrayCustomConvertible.convertFromPostgreSQLArray(_:)`
  public static func convertFromPostgreSQLArray(
    _ data: [Element]
  ) -> Set<Element> {
    return Set(data)
  }

  /// See `PostgreSQLArrayCustomConvertible.convertToPostgreSQLArray(_:)`
  public func convertToPostgreSQLArray() -> [Element] {
    return Array(self)
  }
}

extension Set: ReflectionDecodable {
  /// See `ReflectionDecodable.reflectDecoded()` for more information.
  public static func reflectDecoded() throws -> (Set<Element>, Set<Element>) {
    let reflected = try forceCast(Element.self).anyReflectDecoded()
    return ([reflected.0 as! Element], [reflected.1 as! Element])
  }

  /// See `ReflectionDecodable.reflectDecodedIsLeft(_:)` for more information.
  public static func reflectDecodedIsLeft(_ item: Set<Element>) throws -> Bool {
    return try forceCast(Element.self).anyReflectDecodedIsLeft(item.first!)
  }
}

func forceCast<T>(_ type: T.Type) -> PostgreSQLDataConvertible.Type {

  guard let custom = T.self as? PostgreSQLDataConvertible.Type else {
    fatalError(
      "`\(T.self)` does not conform to `PostgreSQLDataCustomConvertible`"
    )
  }

  return custom
}

func forceCast<T>(_ type: T.Type) throws -> AnyReflectionDecodable.Type {
  guard let casted = T.self as? AnyReflectionDecodable.Type else {
    throw CoreError(
      identifier: "ReflectionDecodable",
      reason: "\(T.self) is not `ReflectionDecodable`",
      suggestedFixes: [
        "Conform `\(T.self)` to `ReflectionDecodable`."
      ]
    )
  }
  return casted
}
