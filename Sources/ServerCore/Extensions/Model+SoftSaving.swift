//
//  Model+SoftSaving.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 21/04/2018.
//

import FluentPostgreSQL
import Fluent

extension PostgreSQLModel {

    func saveIfNeeded(
        on conn: DatabaseConnectable,
        conditions: ModelFilter<Self>...
    ) -> Future<Self> {

        return Future
            .flatMap(on: conn) { () -> Future<Self?> in

                var query = Self.query(on: conn)

                for condition in conditions {
                    query = query.filter(condition)
                }

                return query.first()
            }.flatMap(to: Self.self) { result in
                if let result = result {
                    return conn
                        .eventLoop
                        .newSucceededFuture(result: result)
                } else {
                    return self.save(on: conn)
                }
        }
    }
}
