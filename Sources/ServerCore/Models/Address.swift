//
//  Address.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 31/05/2018.
//

import FluentPostgreSQL

public final class Address: PostgreSQLModel, Migration {

  public typealias UnderlyingID = UUID

  public static var entity: String { return "addresses" }

  public var id: Identifier<Address>?

  public var name: String?

  public var nameEnglish: String?

  /// The name this location is commonly known by.
  public var shortName: String?

  public var shortNameEnglish: String?

  public var city: String?

  public var cityEnglish: String?

  public var street: String?

  public var streetEnglish: String?

  public var house: String?

  public var building: String?

  public var letter: String?

  public var entrance: String?

  public var locationDescription: String

  public var coordinates: PostgreSQLPoint?

  public init(id: Identifier<Address>?,
              name: String? = nil,
              shortName: String? = nil,
              city: String? = nil,
              street: String? = nil,
              house: String? = nil,
              building: String? = nil,
              letter: String? = nil,
              entrance: String? = nil,
              locationDescription: String,
              coordinates: PostgreSQLPoint? = nil) {
    self.id = id
    self.name = name
    self.shortName = shortName
    self.city = city
    self.street = street
    self.house = house
    self.building = building
    self.letter = letter
    self.entrance = entrance
    self.locationDescription = locationDescription
    self.coordinates = coordinates
  }

  public var classrooms: Children<Address, Classroom> {
    return children(\.addressID)
  }
}
