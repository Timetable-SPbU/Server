//
//  StudentGroup.swift
//  ServerCore
//
//  Created by Sergej Jaskiewicz on 29/05/2018.
//

import Fluent
import FluentPostgreSQL
import PostgreSQL
import TimetableSDK
import SPbUappModelsV1

public final class StudentGroup: PostgreSQLModel {

  public var id: Identifier<StudentGroup>?

  public var yearDependentNameFormat: String?

  public var timetableID: StudentGroupID

  public var timetableName: String

  public var profiles: String?

  public var studyForm: StudyForm?

  public var isHidden: Bool

  public var studentStreamID: Identifier<StudentStream>

  public init(yearDependentNameFormat: String?,
              profiles: String?,
              studyForm: String?,
              timetableID: StudentGroupID,
              timetableName: String,
              studentStreamID: Identifier<StudentStream>,
              isHidden: Bool = false) {
    self.yearDependentNameFormat = yearDependentNameFormat
    self.profiles = profiles?.cleanedUp()
    self.studyForm = (studyForm?.cleanedUp()).map(StudyForm.init)
    self.timetableID = timetableID
    self.timetableName = timetableName.cleanedUp()
    self.studentStreamID = studentStreamID
    self.isHidden = isHidden || studyForm == nil
  }

  public var studentStream: Parent<StudentGroup, StudentStream> {
    return parent(\.studentStreamID)
  }
}

extension StudentGroup: Migration {

  /// Runs this migration's changes on the database.
  /// This is usually creating a table, or altering an existing one.
  public static func prepare(on connection: Connection) -> Future<Void> {

    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
      builder.reference(from: \.studentStreamID,
                        to: \StudentStream.id,
                        onUpdate: .cascade,
                        onDelete: .cascade)
      builder.unique(on: \.timetableID)
    }
  }
}
