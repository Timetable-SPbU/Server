//
//  Classroom.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 31/05/2018.
//

import FluentPostgreSQL

public final class Classroom: PostgreSQLModel {

  public typealias UnderlyingID = UUID

  public var id: Identifier<Classroom>?

  public var name: String

  public var nameEnglish: String?

  /// The name this location is commonly known by.
  public var shortName: String?

  public var shortNameEnglish: String?

  public var capacity: Int?

  public var seating: Seating?

  public var additionalInfo: String?

  public var addressID: Identifier<Address>

  public var address: Parent<Classroom, Address> {
    return parent(\.addressID)
  }

  public init(id: Identifier<Classroom>?,
              name: String,
              shortName: String? = nil,
              capacity: Int?,
              seating: Seating?,
              additionalInfo: String?,
              addressID: Identifier<Address>) {
    self.id = id
    self.name = name.cleanedUp()
    self.shortName = shortName?.cleanedUp()
    self.capacity = capacity
    self.seating = seating
    self.additionalInfo = additionalInfo?.cleanedUp()
    self.addressID = addressID
  }
}

extension Classroom: Migration {

  /// Runs this migration's changes on the database.
  /// This is usually creating a table, or altering an existing one.
  public static func prepare(on connection: Connection) -> Future<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
      try builder.addReference(from: \.addressID,
                               to: \Address.id,
                               actions: .update)
    }.then { _ in
      setCustomType(for: \Classroom.seating, on: connection)
    }
  }
}
