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

public final class Specialization: PostgreSQLModel, Migration {

    public var id: Identifier<Specialization>?

    public var name: String

    public var nameEnglish: String?

    public init(name: String,
                nameEnglish: String) {
        self.name = name
        self.nameEnglish = nameEnglish
    }
}
