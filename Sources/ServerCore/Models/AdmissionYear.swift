//
//  AdmissionYear.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 21/04/2018.
//

import FluentPostgreSQL
import Fluent
import Vapor

public final class AdmissionYear: PostgreSQLModel {

    public var id: Identifier<AdmissionYear>?

    public var number: Int

    public var divisionStudyLevelID: Identifier<DivisionStudyLevel>

    public init(number: Int,
                divisionStudyLevelID: Identifier<DivisionStudyLevel>) {
        self.number = number
        self.divisionStudyLevelID = divisionStudyLevelID
    }

    public var parent: Parent<AdmissionYear, DivisionStudyLevel> {
        return parent(\.divisionStudyLevelID)
    }
}

extension AdmissionYear: Migration {

    public static func prepare(
        on connection: PostgreSQLConnection
    ) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addReference(from: \.divisionStudyLevelID,
                                     to: \DivisionStudyLevel.id,
                                     actions: .update)
        }.flatMap(to: Void.self) {
            uniqueConstraint(\AdmissionYear.number,
                             \AdmissionYear.divisionStudyLevelID,
                             on: connection)
        }
    }
}
