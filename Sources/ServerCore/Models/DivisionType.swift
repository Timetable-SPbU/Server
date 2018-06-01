//
//  DivisionType.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 21/04/2018.
//

import FluentPostgreSQL
@_exported import SPbUappModelsV1

extension DivisionType: PostgreSQLEnumType, Migration {

  public static func reflectDecoded() throws -> (DivisionType, DivisionType) {
    return (.highSchool, .faculty)
  }
}
