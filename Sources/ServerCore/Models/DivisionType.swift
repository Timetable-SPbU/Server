//
//  DivisionType.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 21/04/2018.
//

import FluentPostgreSQL
import Vapor
import SPbUappModelsV1

extension DivisionType: PostgreSQLEnumType {
    public static func reflectDecoded() throws -> (DivisionType, DivisionType) {
        return (.highSchool, .faculty)
    }

    public static func convertFromPostgreSQLData(
        _ data: PostgreSQLData
    ) throws -> DivisionType {

        guard let value = data.data else {
            throw PostgreSQLError(
                identifier: "DivisionType",
                reason: "Could not decode DivisionType from `null` data.",
                source: .capture())
        }
        guard let string = String(data: value, encoding: .utf8) else {
            throw PostgreSQLError(identifier: "DivisionType",
                                  reason: "Non-UTF8 string: \(value.hexDebug).",
                                  source: .capture())
        }

        guard let type = DivisionType(rawValue: string) else {
            throw PostgreSQLError(identifier: "DivisionType",
                                  reason: """
                                  Unexpected raw value \(string) \
                                  for DivisionType
                                  """,
                                  source: .capture())
        }

        return type
    }
}
