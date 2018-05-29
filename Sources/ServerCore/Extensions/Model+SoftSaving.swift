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
    on connection: DatabaseConnectable,
    conditions: ModelFilter<Self>...
  ) -> Future<Self> {

    return Future.flatMap(on: connection) { () -> Future<Self?> in

      var query = Self.query(on: connection)

      for condition in conditions {
        query = query.filter(condition)
      }

      return query.first()
    }.flatMap(to: Self.self) { result in
      if let result = result {
        return connection
          .eventLoop
          .newSucceededFuture(result: result)
      } else {
        return self.save(on: connection)
      }
    }
  }
}
