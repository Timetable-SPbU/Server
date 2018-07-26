//
//  Set+PostgreSQLArrayCustomConvertible.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 21/04/2018.
//

import FluentPostgreSQL

extension Set: PostgreSQLDataTypeStaticRepresentable
where Element: PostgreSQLDataTypeStaticRepresentable {

  public static var postgreSQLDataType: PostgreSQLDataType {
    return .array(Element.postgreSQLDataType)
  }
}

extension Set: AnyReflectionDecodable where Element: ReflectionDecodable {
  public static func anyReflectDecoded() throws -> (Any, Any) {
    let reflected = try Element.reflectDecoded()
    return ([reflected.0] as Set, [reflected.1] as Set)
  }
}

extension Set: ReflectionDecodable where Element: ReflectionDecodable {

  public static func reflectDecoded() throws -> (Set<Element>, Set<Element>) {
    let reflected = try Element.reflectDecoded()
    return ([reflected.0], [reflected.1])
  }
}
