//
//  Division.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 16/04/2018.
//

import FluentPostgreSQL
import Fluent
import Vapor

public final class Division: PostgreSQLModel {

    public var id: Int?

    public var facultyName: String

    public var officialDivisionName: String

    public var facultyNameEnglish: String

    public var officialDivisionNameEnglish: String

    public var code: String

    public init(facultyName: String,
                officialDivisionName: String,
                facultyNameEnglish: String,
                officialDivisionNameEnglish: String,
                code: String) {
        self.facultyName = facultyName
        self.officialDivisionName = officialDivisionName
        self.facultyNameEnglish = facultyNameEnglish
        self.officialDivisionNameEnglish = officialDivisionNameEnglish
        self.code = code
    }
}

extension Division: Content {}
extension Division: Migration {}
