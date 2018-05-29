//
//  DivisionType.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 21/04/2018.
//

import FluentPostgreSQL
@_exported import SPbUappModelsV1

extension DivisionType: PostgreSQLEnumType {

  public static func reflectDecoded() throws -> (DivisionType, DivisionType) {
    return (.highSchool, .faculty)
  }

  public static func convertFromPostgreSQLData(
    _ data: PostgreSQLData
  ) throws -> DivisionType {

    guard let value = data.data else {
      throw PostgreSQLError(
        identifier: "\(DivisionType.self).nullData",
        reason: "Could not decode DivisionType from `null` data.",
        source: .capture()
      )
    }
    guard let string = String(data: value, encoding: .utf8) else {
      throw PostgreSQLError(
        identifier: "\(DivisionType.self).UTF8",
        reason: "Non-UTF8 string: \(value.hexDebug).",
        source: .capture()
      )
    }

    guard let type = DivisionType(rawValue: string) else {
      throw PostgreSQLError(
        identifier: "\(DivisionType.self).unexpectedValue",
        reason: """
        Unexpected raw value \(string) \
        for \(DivisionType.self)
        """,
        source: .capture()
      )
    }

    return type
  }
}

extension DivisionType: Migration {

  public typealias Database = PostgreSQLDatabase
  public typealias Connection = PostgreSQLConnection

  public static func prepare(on connection: Connection) -> Future<Void> {

    let cases = allCases.map { "'\($0.rawValue)'" }.joined(separator: ", ")

    let query = """
    CREATE TYPE "\(self)" AS ENUM (\(cases));

    -- Allow implicit casting from TEXT to \(self)
    CREATE OR REPLACE FUNCTION "text2\(self)"(TEXT)
      RETURNS "\(self)" AS $$
        SELECT $1::"\(self)";
      $$ LANGUAGE SQL IMMUTABLE;

    CREATE CAST (TEXT AS "\(self)")
      WITH FUNCTION "text2\(self)"(TEXT) AS IMPLICIT;
    """

    return connection.simpleQuery(query).transform(to: ())
  }

  public static func revert(on connection: Connection) -> Future<Void> {

    let query = """
    DROP CAST IF EXISTS(TEXT AS "\(self)");
    DROP FUNCTION IF EXISTS "text2\(self)"(TEXT);
    DROP TYPE IF EXISTS "\(self)";
    """

    return connection.simpleQuery(query).transform(to: ())
  }
}
