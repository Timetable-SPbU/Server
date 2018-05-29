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

    public var divisionStudyLevelLinkID: Identifier<DivisionStudyLevel>

    public init(number: Int,
                divisionStudyLevelLinkID: Identifier<DivisionStudyLevel>) {
        self.number = number
        self.divisionStudyLevelLinkID = divisionStudyLevelLinkID
    }

    public var parent: Parent<AdmissionYear, DivisionStudyLevel> {
        return parent(\.divisionStudyLevelLinkID)
    }
}

extension AdmissionYear: Migration {

    public static func prepare(
        on connection: PostgreSQLConnection
    ) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addReference(from: \.divisionStudyLevelLinkID,
                                     to: \DivisionStudyLevel.id)
        }.flatMap(to: Void.self) {

            let numberColumnName = try (\AdmissionYear.number)
                .makeQueryField()
                .name

            let divisionStudyLevelLinkIDColumnName =
                try (\AdmissionYear.divisionStudyLevelLinkID)
                    .makeQueryField()
                    .name

            let query = """
            ALTER TABLE "\(entity)"
                ADD CONSTRAINT "year_uniqueness"
                UNIQUE("\(numberColumnName)", \
                "\(divisionStudyLevelLinkIDColumnName)");
            """

            return connection.simpleQuery(query).transform(to: ())
        }
    }
}
