//
//  DivisionStudyLevel.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 19/04/2018.
//

import Fluent
import FluentPostgreSQL
import PostgreSQL

public final class DivisionStudyLevel: PostgreSQLPivot, ModifiablePivot {

    public typealias Left = Division

    public typealias Right = StudyLevel

    public var id: Identifier<DivisionStudyLevel>?

    public var divisionID: Identifier<Division>

    public var studyLevelID: Identifier<StudyLevel>

    public static var leftIDKey: LeftIDKey { return \.divisionID }

    public static var rightIDKey: RightIDKey { return \.studyLevelID }

    public init(_ left: Division, _ right: StudyLevel) throws {
        self.divisionID = try left.requireID()
        self.studyLevelID = try right.requireID()
    }

    public var admissionYears: Children<DivisionStudyLevel, AdmissionYear> {
        return children(\.divisionStudyLevelID)
    }
}

extension DivisionStudyLevel: Migration {
    
    /// Runs this migration's changes on the database.
    /// This is usually creating a table, or altering an existing one.
    public static func prepare(
        on connection: Database.Connection
    ) -> Future<Void> {
        
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addReference(from: \.divisionID,
                                     to: \Division.id,
                                     actions: .update)
            try builder.addReference(from: \.studyLevelID,
                                     to: \StudyLevel.id,
                                     actions: .update)
        }
    }
}
