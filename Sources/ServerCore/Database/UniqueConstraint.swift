//
//  UniqueConstraint.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 30/05/2018.
//

import Fluent
import FluentPostgreSQL

internal struct UniqueConstraint<M: PostgreSQLModel> {

  let name: String

  private let query: String

  init(_ keyPaths: [PartialKeyPath<M>]) throws {

    let columns = try keyPaths.map { try $0.makeQueryFieldPartial().name }

    name = columns.joined(separator: "_") + "_UNIQUE_in_\(M.entity)"

    let list = columns.map { "\"\($0)\"" }.joined(separator: ", ")

    query = """
    ALTER TABLE "\(M.entity)"
      ADD CONSTRAINT "\(name)" UNIQUE(\(list));
    """
  }

  init(_ keyPaths: PartialKeyPath<M>...) throws {
    try self.init(keyPaths)
  }

  func activate(on connection: PostgreSQLConnection) -> Future<Void> {
    return connection.simpleQuery(query).transform(to: ())
  }
}

extension UniqueConstraint {

  static func activate(_ constraints: [UniqueConstraint<M>],
                       on connection: PostgreSQLConnection) -> Future<Void> {
    let query = constraints.map { $0.query }.joined(separator: "\n")
    return connection.simpleQuery(query).transform(to: ())
  }
}

