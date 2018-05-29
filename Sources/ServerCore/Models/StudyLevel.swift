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

    var divisions: Siblings<StudyLevel, Division, DivisionStudyLevel> {
        return siblings()
    }

    public init(name: String,
                nameEnglish: String?,
                timetableName: String,
                divisionTypes: Set<DivisionType> = []) {
        self.name = name
        self.nameEnglish = nameEnglish
        self.timetableName = timetableName
        self.divisionTypes = divisionTypes
    }
}

extension StudyLevel: Migration {
    
    /// Runs this migration's changes on the database.
    /// This is usually creating a table, or altering an existing one.
    public static func prepare(
        on connection: PostgreSQLConnection
    ) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
        }.flatMap(to: Void.self) {
            setCustomType(for: \.divisionTypes, on: connection)
        }
    }
}
