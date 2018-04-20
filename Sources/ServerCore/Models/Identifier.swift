//
//  Identifier.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 18/04/2018.
//

import Vapor
import Fluent
import FluentPostgreSQL

public struct Identifier<Model: PostgreSQLModel>:
    ID, RawRepresentable, PostgreSQLDataConvertible,
    ReflectionDecodable, PostgreSQLColumnStaticRepresentable {

    public var rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(Int.self))
    }
}
