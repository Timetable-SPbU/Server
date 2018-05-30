//
//  Educator.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 30/05/2018.
//

import FluentPostgreSQL
import Fluent
import TimetableSDK

public final class Educator: PostgreSQLModel {

  public var id: Identifier<Educator>?

  public var firstName: String

  public var middleName: String?

  public var lastName: String?

  public var firstNameEnglish: String?

  public var middleNameEnglish: String?

  public var lastNameEnglish: String?

  public var timetableID: EducatorID

  public init(firstName: String,
              middleName: String?,
              lastName: String?,
              firstNameEnglish: String? = nil,
              middleNameEnglish: String? = nil,
              lastNameEnglish: String? = nil,
              timetableID: EducatorID) {
    self.firstName = firstName
    self.middleName = middleName
    self.lastName = lastName
    self.firstNameEnglish = firstNameEnglish
    self.middleNameEnglish = middleNameEnglish
    self.lastNameEnglish = lastNameEnglish
    self.timetableID = timetableID
  }

  static let uniqueConstraint = try! UniqueConstraint(\Educator.timetableID)
}

extension Educator: Migration {

  /// Runs this migration's changes on the database.
  /// This is usually creating a table, or altering an existing one.
  public static func prepare(
    on connection: PostgreSQLConnection
  ) -> Future<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
    }.flatMap(to: Void.self) {
      uniqueConstraint.activate(on: connection)
    }
  }
}
