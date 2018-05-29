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

public final class Division: PostgreSQLModel {

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

extension Division: Migration {
    
    /// Runs this migration's changes on the database.
    /// This is usually creating a table, or altering an existing one.
    public static func prepare(
        on connection: PostgreSQLConnection
    ) -> Future<Void> {
        
        return DivisionType.createType(on: connection)
            .flatMap(to: Void.self) { _ in
                Database.create(self, on: connection) { builder in
                    try addProperties(to: builder)
                }
            }.flatMap(to: Void.self) {
                
                // Fluent cannot (yet?) assign a custom type to columns, so we
                // need to do it manually.
                
                return setCustomType(for: \.type, on: connection)
            }
    }
    
    /// Reverts this migration's changes on the database.
    /// This is usually dropping a created table. If it is not possible
    /// to revert the changes from this migration, complete the future
    /// with an error.
    public static func revert(
        on connection: Database.Connection
    ) -> Future<Void> {
        
        return Database.delete(self, on: connection)
            .flatMap(to: Void.self) {
                DivisionType.dropType(on: connection)
            }
    }
}

extension Division: Parameter {}
