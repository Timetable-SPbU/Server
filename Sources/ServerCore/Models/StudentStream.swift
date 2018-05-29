//
//  StudentStream.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 21/04/2018.
//

import Fluent
import FluentPostgreSQL
import PostgreSQL

public final class StudentStream: PostgreSQLPivot, ModifiablePivot, Migration {

    public typealias Left = AdmissionYear

    public typealias Right = Specialization

    public var id: Identifier<StudentStream>?

    public var admissionYearID: Identifier<AdmissionYear>

    public var specializationID: Identifier<Specialization>

    public static var leftIDKey: LeftIDKey { return \.admissionYearID }

    public static var rightIDKey: RightIDKey { return \.specializationID }

    public init(_ left: AdmissionYear, _ right: Specialization) throws {
        self.admissionYearID = try left.requireID()
        self.specializationID = try right.requireID()
    }
}
