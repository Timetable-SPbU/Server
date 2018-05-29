//
//  PostgreSQLModel.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 18/04/2018.
//

import FluentPostgreSQL
import Fluent
import Vapor

/// Reimplementation of `FluentPostgreSQL.PostgreSQLModel`
/// with strongly typed ID.
public protocol PostgreSQLModel: Model
  where Self.Database == PostgreSQLDatabase {

  typealias Connection = Database.Connection

  /// This model's unique identifier.
  var id: Identifier<Self>? { get set }
}

extension PostgreSQLModel where Self.ID == Identifier<Self>  {

  public static var idKey: IDKey { return \.id }

  public func didCreate(
    on connection: PostgreSQLConnection
  ) throws -> Future<Self> {

    return connection
      .simpleQuery("SELECT LASTVAL();")
      .map(to: Self.self) { row in
        var model = self
        let intID = try row.first?
          .firstValue(forColumn: "lastval")?
          .decode(Int.self)

        model.fluentID = intID.map(Identifier<Self>.init)
        return model
    }
  }
}

extension PostgreSQLModel {

  private static func _setCustomType<T>(
    for column: KeyPath<Self, T>,
    typeName: String,
    on connection: PostgreSQLConnection
  ) -> Future<Void> {

    return Future.flatMap(on: connection) { () -> Future<Void> in

      let columnName = try column.makeQueryField().name

      let alterColumnType = """
      ALTER TABLE "\(entity)"
      ALTER COLUMN "\(columnName)" TYPE \(typeName)
      USING "\(columnName)"::\(typeName);
      """

      return connection.simpleQuery(alterColumnType).transform(to: ())
    }
  }

  /// Alters the column to set a custom type.
  static func setCustomType<T: PostgreSQLType>(
    for column: KeyPath<Self, T>,
    on connection: PostgreSQLConnection
  ) -> Future<Void> {
    return _setCustomType(for: column,
                          typeName: "\"\(T.self)\"",
                          on: connection)
  }

  // Alters the column to set a custom array type.
  static func setCustomType<T: PostgreSQLArrayType>(
    for column: KeyPath<Self, T>,
    on connection: PostgreSQLConnection
  ) -> Future<Void> {
    return _setCustomType(for: column,
                          typeName: "\"\(T.PostgreSQLArrayElement.self)\"[]",
                          on: connection)
  }

  static func uniqueConstraint(
    _ keyPaths: PartialKeyPath<Self>...,
    on connection: PostgreSQLConnection
  ) -> Future<Void> {

    return Future.flatMap(on: connection) { () -> Future<Void> in

      let columns = try keyPaths.map { try $0.makeQueryFieldPartial().name }

      let constraintName = columns.joined(separator: "_") + "_UNIQUE"
      let list = columns.map { "\"\($0)\"" }.joined(separator: ", ")

      let query = """
      ALTER TABLE "\(entity)"
        ADD CONSTRAINT "\(constraintName)" UNIQUE(\(list));
      """

      return connection.simpleQuery(query).transform(to: ())
    }
  }
}

public protocol PostgreSQLPivot: Pivot, PostgreSQLModel {}

extension PostgreSQLPivot {

  /// Use this implementation if `PostgreSQLPivot` conforms to `Migration`.
  public static func prepare(
    on connection: PostgreSQLConnection
  ) -> Future<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
    }.flatMap(to: Void.self) {
      uniqueConstraint(leftIDKey, rightIDKey, on: connection)
    }
  }

}

