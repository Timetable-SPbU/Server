//
//  StudyLevel.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 18/04/2018.
//

import FluentPostgreSQL
import Fluent
import Vapor

public final class StudyLevel: PostgreSQLModel, Migration {

    public var id: Identifier<StudyLevel>?

    public var name: String

    public var nameEnglish: String?

    public var timetableName: String

    var divisions: Siblings<StudyLevel, Division, DivisionStudyLevel> {
        return siblings()
    }

    public init(name: String,
                nameEnglish: String?,
                timetableName: String) {
        self.name = name
        self.nameEnglish = nameEnglish
        self.timetableName = timetableName
    }
}
