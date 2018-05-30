//
//  StudentStream.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 21/04/2018.
//

import Fluent
import FluentPostgreSQL
import PostgreSQL
import TimetableSDK

public final class StudentStream: PostgreSQLModel {

  public var id: Identifier<StudentStream>?

  public var year: Int

  public var timetableStudyProgramID: StudyProgramID

  public var specializationID: Identifier<Specialization>

  public init(year: Int,
              timetableStudyProgramID: StudyProgramID,
              specializationID: Identifier<Specialization>) {
    self.year = year
    self.timetableStudyProgramID = timetableStudyProgramID
    self.specializationID = specializationID
  }

  public var studentGroups: Children<StudentStream, StudentGroup> {
    return children(\.studentStreamID)
  }

  static let uniqueConstraint =
    try! UniqueConstraint(\StudentStream.year, \StudentStream.specializationID)
}

extension StudentStream: Migration {

  /// Runs this migration's changes on the database.
  /// This is usually creating a table, or altering an existing one.
  public static func prepare(on connection: Connection) -> Future<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
      try builder.addReference(from: \.specializationID,
                               to: \Specialization.id,
                               actions: .update)
    }.flatMap(to: Void.self) {
      uniqueConstraint.activate(on: connection)
    }
  }
}
