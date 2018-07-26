//
//  Seating.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 31/05/2018.
//

import FluentPostgreSQL
import TimetableSDK
import SPbUappModelsV1

public typealias Seating = SPbUappModelsV1.Seating

extension Seating: PostgreSQLEnum, PostgreSQLMigration {}

extension Seating {
  internal init(_ seating: TimetableSDK.Seating) {
    switch seating {
    case .theater:
      self = .theater
    case .amphitheater:
      self = .amphitheater
    case .roundtable:
      self = .roundtable
    }
  }
}
