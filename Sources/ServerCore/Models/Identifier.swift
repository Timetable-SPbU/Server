//
//  Identifier.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 18/04/2018.
//

import Vapor
import Fluent
import FluentPostgreSQL
import TimetableSDK
import SPbUappModelsV1

public typealias GenericIdentifier = PostgreSQLDataConvertible &
                                     ReflectionDecodable &
                                     PostgreSQLColumnStaticRepresentable

public struct Identifier<Model: PostgreSQLModel>: ID,
  RawRepresentable, GenericIdentifier {

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

extension DivisionAlias: GenericIdentifier {
  public static func reflectDecoded() throws -> (DivisionAlias, DivisionAlias) {
    let rawValues = String.reflectDecoded()
    return (.init(rawValue: rawValues.0), .init(rawValue: rawValues.1))
  }
}

extension StudyProgramID: GenericIdentifier {}

extension StudentGroupID: GenericIdentifier {}

extension EducatorID: GenericIdentifier {}

extension StudyForm: GenericIdentifier {
  public static func reflectDecoded() throws -> (StudyForm, StudyForm) {
    let rawValues = String.reflectDecoded()
    return (.init(rawValue: rawValues.0), .init(rawValue: rawValues.1))
  }
}
