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
public protocol PostgreSQLModel: _PostgreSQLModel {

  typealias Connection = Database.Connection

  associatedtype UnderlyingID: Hashable,
                               Fluent.ID,
                               PostgreSQLDataConvertible,
                               PostgreSQLDataTypeStaticRepresentable,
                               ReflectionDecodable = Int

  /// This model's unique identifier.
  var id: Identifier<Self>? { get set }
}

extension PostgreSQLModel where ID == Identifier<Self> {
  public static var idKey: IDKey { return \.id }
}

// MARK: - Upsert

extension QueryBuilder
where Result: PostgreSQLModel, Result.Database == Database {

  /// Creates the model or updates it depending on whether a model
  /// with the same ID already exists.
  internal func upsert(_ model: Result,
                       columns: [PostgreSQLColumnIdentifier]) -> Future<Result> {

    let row = SQLQueryEncoder(PostgreSQLExpression.self).encode(model)

    let values = row
      .map { row -> (PostgreSQLIdentifier, PostgreSQLExpression) in
        return (.identifier(row.key), row.value)
      }

    self.query.upsert = .upsert(columns, values)
    return create(model)
  }

}

extension PostgreSQLModel {

  /// Creates the model or updates it depending on whether a model
  /// with the same ID already exists.
  internal func upsert(on connection: DatabaseConnectable) -> Future<Self> {
    return Self
      .query(on: connection)
      .upsert(self, columns: [.keyPath(Self.idKey)])
  }

  internal func upsert<U>(on connection: DatabaseConnectable,
                          onConflict keyPath: KeyPath<Self, U>) -> Future<Self> {
    return Self
      .query(on: connection)
      .upsert(self, columns: [.keyPath(keyPath)])
  }

  internal func upsert<U, V>(on connection: DatabaseConnectable,
                             onConflict keyPath1: KeyPath<Self, U>,
                             _ keyPath2: KeyPath<Self, V>) -> Future<Self> {
    return Self
      .query(on: connection)
      .upsert(self, columns: [.keyPath(keyPath1), .keyPath(keyPath2)])
  }
}

// MARK: - Many-to-many
public protocol PostgreSQLPivot: Pivot, PostgreSQLModel
where Left: PostgreSQLModel,
      Right: PostgreSQLModel,
      Left.ID == Identifier<Left>,
      Right.ID == Identifier<Right> {}

extension PostgreSQLPivot {

  /// Use this implementation if `PostgreSQLPivot` conforms to `Migration`.
  public static func prepare(on connection: Connection) -> Future<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
      builder.reference(from: leftIDKey,
                        to: \Left.id,
                        onUpdate: .cascade,
                        onDelete: .cascade)
      builder.reference(from: rightIDKey,
                        to: \Right.id,
                        onUpdate: .cascade,
                        onDelete: .cascade)
      builder.unique(on: leftIDKey, rightIDKey)
    }
  }

}

