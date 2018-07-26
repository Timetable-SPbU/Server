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
}

extension StudentStream: Migration {
  public static func prepare(on connection: Connection) -> Future<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
      builder.reference(from: \.specializationID,
                        to: \Specialization.id,
                        onUpdate: .cascade,
                        onDelete: .cascade)
      builder.unique(on: \.year, \.specializationID)
    }
  }
}
