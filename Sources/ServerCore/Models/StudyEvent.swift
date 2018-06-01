//
//  StudyEvent.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 31/05/2018.
//

import Foundation
import FluentPostgreSQL

public final class StudyEvent: PostgreSQLModel, Timestampable {

  public static var createdAtKey: WritableKeyPath<StudyEvent, Date?> {
    return \.createdAt
  }

  public static var updatedAtKey: WritableKeyPath<StudyEvent, Date?> {
    return \.updatedAt
  }

  public typealias UnderlyingID = UUID

  public var id: Identifier<StudyEvent>?

  public var createdAt: Date?

  public var updatedAt: Date?

  public var start: Date

  public var end: Date

  public var name: String

  public var isCancelled: Bool

  public var timeChanged: Bool

  public var locationsChanged: Bool

  public var educatorsReassigned: Bool

  public var isElective: Bool

  public var isStudy: Bool

  public var allDay: Bool

  public var withinTheSameDay: Bool

  public init(start: Date,
              end: Date,
              name: String,
              isCancelled: Bool,
              timeChanged: Bool,
              locationsChanged: Bool,
              educatorsReassigned: Bool,
              isElective: Bool,
              isStudy: Bool,
              allDay: Bool,
              withinTheSameDay: Bool) {
    self.start = start
    self.end = end
    self.name = name
    self.isCancelled = isCancelled
    self.timeChanged = timeChanged
    self.locationsChanged = locationsChanged
    self.educatorsReassigned = educatorsReassigned
    self.isElective = isElective
    self.isStudy = isStudy
    self.allDay = allDay
    self.withinTheSameDay = withinTheSameDay
  }
}
