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

extension Division: Migration {}

extension Division: Parameter {}
