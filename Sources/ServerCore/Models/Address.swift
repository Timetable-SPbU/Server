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
    self.name = name?.cleanedUp()
    self.shortName = shortName?.cleanedUp()
    self.city = city?.cleanedUp()
    self.street = street?.cleanedUp()
    self.house = house?.cleanedUp()
    self.building = building?.cleanedUp()
    self.letter = letter?.cleanedUp()
    self.entrance = entrance?.cleanedUp()
    self.locationDescription = locationDescription.cleanedUp()
    self.coordinates = coordinates
  }

  public var classrooms: Children<Address, Classroom> {
    return children(\.addressID)
  }
}
