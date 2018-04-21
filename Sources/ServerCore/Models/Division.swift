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

public final class Division: PostgreSQLModel, Migration {

    public var id: Identifier<Division>?

    public var divisionName: String

    public var fieldOfStudy: String

    public var divisionNameEnglish: String

    public var fieldOfStudyEnglish: String

    public var code: String

    public var type: DivisionType

    public var studyLevels: Siblings<Division, StudyLevel, DivisionStudyLevel> {
        return siblings()
    }

    public init(divisionName: String,
                fieldOfStudy: String,
                divisionNameEnglish: String,
                fieldOfStudyEnglish: String,
                code: String,
                type: DivisionType = .faculty) {
        self.divisionName = divisionName
        self.fieldOfStudy = fieldOfStudy
        self.divisionNameEnglish = divisionNameEnglish
        self.fieldOfStudyEnglish = fieldOfStudyEnglish
        self.code = code
        self.type = type
    }
}

extension Division: Parameter {}
