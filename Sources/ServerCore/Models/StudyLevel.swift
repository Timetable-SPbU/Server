//
//  StudyLevel.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 18/04/2018.
//

import FluentPostgreSQL
import Fluent
import Vapor
import SPbUappModelsV1

public final class StudyLevel: PostgreSQLModel {

  public var id: Identifier<StudyLevel>?

  public var name: String

  public var nameEnglish: String?

  public var timetableName: String

  public var divisionTypes: Set<DivisionType>

  public var divisions: Siblings<StudyLevel, Division, DivisionStudyLevel> {
    return siblings()
  }

  public init(name: String,
              nameEnglish: String?,
              timetableName: String,
              divisionTypes: Set<DivisionType> = []) {
    self.name = name.cleanedUp()
    self.nameEnglish = nameEnglish?.cleanedUp()
    self.timetableName = timetableName.cleanedUp()
    self.divisionTypes = divisionTypes
  }
}

extension StudyLevel: Migration {

  public static func prepare(on connection: Connection) -> Future<Void> {
    return Database.create(self, on: connection) { builder in

      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.name)
      builder.field(for: \.nameEnglish)
      builder.field(for: \.timetableName)
      builder.field(for: \.divisionTypes)

      builder.unique(on: \.timetableName)
    }
  }
}
