//
//  Division.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 16/04/2018.
//

import FluentPostgreSQL
import Fluent
import Vapor
import DatabaseKit
import PostgreSQL
import SPbUappModelsV1
import TimetableSDK

public final class Division: PostgreSQLModel {

  public var id: Identifier<Division>?

  public var divisionName: String

  public var fieldOfStudy: String

  public var divisionNameEnglish: String

  public var fieldOfStudyEnglish: String

  public var code: DivisionAlias

  public var type: DivisionType

  public var studyLevels: Siblings<Division, StudyLevel, DivisionStudyLevel> {
    return siblings()
  }

  public init(divisionName: String,
              fieldOfStudy: String,
              divisionNameEnglish: String,
              fieldOfStudyEnglish: String,
              code: DivisionAlias,
              type: DivisionType = .faculty) {
    self.divisionName = divisionName
    self.fieldOfStudy = fieldOfStudy
    self.divisionNameEnglish = divisionNameEnglish
    self.fieldOfStudyEnglish = fieldOfStudyEnglish
    self.code = code
    self.type = type
  }
}

extension Division: Migration {

  /// Runs this migration's changes on the database.
  /// This is usually creating a table, or altering an existing one.
  public static func prepare(on connection: Connection) -> Future<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
    }.flatMap(to: Void.self) {
      // Fluent cannot (yet?) assign a custom type to columns, so we
      // need to do it manually.
      return setCustomType(for: \.type, on: connection)
    }
  }
}

extension Division: Parameter {}
