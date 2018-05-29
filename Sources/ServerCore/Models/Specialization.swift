//
//  Specialization.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 21/04/2018.
//

import FluentPostgreSQL
import Fluent
import Vapor
import TimetableSDK

public final class Specialization: PostgreSQLModel {

    public var id: Identifier<Specialization>?

    public var name: String

    public var nameEnglish: String?
    
    public var divisionStudyLevelID: Identifier<DivisionStudyLevel>

    public init(name: String,
                nameEnglish: String,
                divisionStudyLevelID: Identifier<DivisionStudyLevel>) {
        self.name = name
        self.nameEnglish = nameEnglish
        self.divisionStudyLevelID = divisionStudyLevelID
    }
}

extension Specialization: Migration {
    
    /// Runs this migration's changes on the database.
    /// This is usually creating a table, or altering an existing one.
    public static func prepare(
        on connection: PostgreSQLConnection
    ) -> Future<Void> {

        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addReference(from: \.divisionStudyLevelID,
                                     to: \DivisionStudyLevel.id,
                                     actions: .update)
        }
    }
}
