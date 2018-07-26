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
                                     PostgreSQLDataTypeStaticRepresentable

extension RawRepresentable
where RawValue: PostgreSQLDataTypeStaticRepresentable {
  public static var postgreSQLDataType: PostgreSQLDataType {
    return RawValue.postgreSQLDataType
  }
}

public struct Identifier<Model: PostgreSQLModel>:
  ID,
  RawRepresentable,
  GenericIdentifier
{
  public var rawValue: Model.UnderlyingID

  public init(rawValue: Model.UnderlyingID) {
    self.rawValue = rawValue
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.init(rawValue: try container.decode(Model.UnderlyingID.self))
  }

  public static func reflectDecoded() throws -> (
    Identifier<Model>, Identifier<Model>
  ) {
    let (left, right) = try RawValue.reflectDecoded()
    return (.init(rawValue: left), .init(rawValue: right))
  }
}

extension DivisionAlias: GenericIdentifier {
  public static func reflectDecoded() throws -> (DivisionAlias, DivisionAlias) {
    let rawValues = String.reflectDecoded()
    return (.init(rawValue: rawValues.0), .init(rawValue: rawValues.1))
  }
}

extension StudyProgramID: GenericIdentifier {
  public static func reflectDecoded() throws -> (
    StudyProgramID,
    StudyProgramID
  ) {
    let rawValues = Int.reflectDecoded()
    return (.init(rawValue: rawValues.0), .init(rawValue: rawValues.1))
  }
}

extension StudentGroupID: GenericIdentifier {
  public static func reflectDecoded() throws -> (
    StudentGroupID,
    StudentGroupID
  ) {
    let rawValues = Int.reflectDecoded()
    return (.init(rawValue: rawValues.0), .init(rawValue: rawValues.1))
  }
}

extension EducatorID: GenericIdentifier {
  public static func reflectDecoded() throws -> (
    EducatorID,
    EducatorID
  ) {
    let rawValues = Int.reflectDecoded()
    return (.init(rawValue: rawValues.0), .init(rawValue: rawValues.1))
  }
}

extension StudyForm: GenericIdentifier {
  public static func reflectDecoded() throws -> (StudyForm, StudyForm) {
    let rawValues = String.reflectDecoded()
    return (.init(rawValue: rawValues.0), .init(rawValue: rawValues.1))
  }
}
