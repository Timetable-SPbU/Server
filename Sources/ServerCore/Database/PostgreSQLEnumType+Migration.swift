//
//  PostgreSQLEnumType+Migration.swift
//  SPbUappModelsV1
//
//  Created by Sergej Jaskiewicz on 31/05/2018.
//

import FluentPostgreSQL

extension PostgreSQLEnumType
  where Self: RawRepresentable, RawValue == String, Self: CaseIterable {

  public static func convertFromPostgreSQLData(
    _ data: PostgreSQLData
  ) throws -> Self {

    guard let value = data.data else {
      throw PostgreSQLError(
        identifier: "\(self).nullData",
        reason: "Could not decode \(self) from `null` data.",
        source: .capture()
      )
    }
    guard let string = String(data: value, encoding: .utf8) else {
      throw PostgreSQLError(
        identifier: "\(self).UTF8",
        reason: "Non-UTF8 string: \(value.hexDebug).",
        source: .capture()
      )
    }

    guard let type = Self(rawValue: string) else {
      throw PostgreSQLError(
        identifier: "\(self).unexpectedValue",
        reason: """
        Unexpected raw value \(string) \
        for \(self)
        """,
        source: .capture()
      )
    }

    return type
  }

  public typealias Database = PostgreSQLDatabase
  public typealias Connection = PostgreSQLConnection

  public static func prepare(on connection: Connection) -> Future<Void> {

    let cases = allCases.map { "'\($0.rawValue)'" }.joined(separator: ", ")

    let conversions = allCases.map {
      "      WHEN '\($0.rawValue)' THEN '\($0.rawValue)'::\"\(self)\""
    }.joined(separator: "\n")

    let query = """
    CREATE TYPE "\(self)" AS ENUM (\(cases));

    -- Allow implicit casting from TEXT to \(self)
    CREATE OR REPLACE FUNCTION "text2\(self)"(TEXT)
      RETURNS "\(self)" AS $$
        SELECT CASE $1
    \(conversions)
        END;
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
