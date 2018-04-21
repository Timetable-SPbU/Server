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

    /// This model's unique identifier.
    var id: Identifier<Self>? { get set }
}

extension PostgreSQLModel where Self.ID == Identifier<Self>  {

    public static var idKey: IDKey { return \.id }

    public func didCreate(
        on connection: PostgreSQLConnection
    ) throws -> EventLoopFuture<Self> {

        return connection
            .simpleQuery("SELECT LASTVAL();")
            .map(to: Self.self) { row in
                var model = self
                let intID = try row[0]
                    .firstValue(forColumn: "lastval")?
                    .decode(Int.self)

                model.fluentID = intID.map(Identifier<Self>.init)
                return model
            }
    }
}

public protocol PostgreSQLPivot: Pivot, PostgreSQLModel { }

extension PostgreSQLPivot {

    /// Use this implementation if `PostgreSQLPivot` conforms to `Migration`.
    public static func prepare(
        on connection: PostgreSQLConnection
    ) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
        }.flatMap(to: Void.self) {

            let query = try """
            ALTER TABLE "\(name)"
                ADD CONSTRAINT "relation_uniqueness"
                UNIQUE("\(leftIDKey.makeQueryField().name)", \
                       "\(rightIDKey.makeQueryField().name)");
            """

            return connection.simpleQuery(query).transform(to: ())
        }
    }

}

