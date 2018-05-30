//
//  TimetableDumper.swift
//  TimetableDump
//
//  Created by Sergej Jaskiewicz on 20/04/2018.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Fluent
import TimetableSDK

public final class TimetableDumper {

  /// We use proxy servers to surpass the timetable.spbu.ru API limit
  /// of 1500 requests per day.
  private let proxyPool: ProxyPool?
  private let logger: Logger
  private let worker: Worker
  private let database: DatabaseConnectable

  private let baseURLComponents =
    URLComponents(string: "https://timetable.spbu.ru")!

  private var client: HTTPClient? {
    willSet {
      assert(client == nil)
    }
  }

  public init(container: Container,
              database: DatabaseConnectable,
              useProxy: Bool) throws {
    proxyPool = useProxy ? try ProxyPool(container) : nil
    logger = try container.make(Logger.self)
    self.worker = container
    self.database = database
  }

  deinit {
    _ = client?.close()
  }

  // MARK: - Dumping the timetable

  public func dumpTimetable() -> Future<Void> {
    return Division.query(on: database).all()
      .flatMap(to: Void.self) { divisions in
        divisions.serialFutureMap(on: self.database, self.dumpDivision)
      }
  }

  private func dumpDivision(_ division: Division) -> Future<Void> {

    let request = StudyLevelRequest(divisionAlias: division.code)

    return perform(request).flatMap(to: Void.self) { studyLevels in
      studyLevels.serialFutureMap(on: self.database) {
        self.saveStudyLevel(timetableStudyLevel: $0, division: division)
      }
    }
  }

  private func saveStudyLevel(
    timetableStudyLevel: TimetableSDK.StudyLevel,
    division: Division
  ) -> Future<Void> {

    guard let name = timetableStudyLevel.name else {
      // Don't process the study levels that don't have names — it doesn't
      // make sence.
      return database.eventLoop.newSucceededFuture(result: ())
    }

    let studyLevel = StudyLevel(
      name: name,
      nameEnglish: timetableStudyLevel.englishName,
      timetableName: name
    )

    self.logger.debug("""
                      Fetched study level "\(studyLevel.name)". Saving...
                      """)

    return Future.flatMap(on: database) {
      try studyLevel.saveIfNeeded(
        on: self.database,
        conditions: \.timetableName == studyLevel.timetableName
      )
    }.flatMap(to: Void.self) { studyLevel in

      self.logger.debug("""
                        Creating connection between study level \
                        "\(studyLevel.name)" and \
                        division "\(division.divisionName)"
                        """)

      if studyLevel.divisionTypes.isEmpty ||
        studyLevel.divisionTypes.contains(division.type) {
        return division
          .studyLevels
          .attachIfNeeded(studyLevel, on: self.database)
          .flatMap(to: Void.self) { divisionStudyLevel in
            self.saveSpecializations(divisionStudyLevel: divisionStudyLevel,
                                     programs: timetableStudyLevel.programs)
        }
      } else {
        return self.database.eventLoop.newSucceededFuture(result: ())
      }
    }
  }

  private func saveSpecializations(
    divisionStudyLevel: DivisionStudyLevel,
    programs: [TimetableSDK.StudyLevel.Program]
  ) -> Future<Void> {

    return programs
      .serialFutureMap(on: database) { program -> Future<Void> in

        let db = self.database

        guard let name = program.name else {
          // Don't process the specializatioins that don't have names —
          // it doesn't make sence.
          return self.database.eventLoop.newSucceededFuture(result: ())
        }

        return Future.flatMap(on: db) {

          let specialization = try Specialization(
            name: name,
            nameEnglish: program.englishName,
            divisionStudyLevelID: divisionStudyLevel.requireID()
          )

          return try specialization.saveIfNeeded(
            on: self.database,
            conditions:
              \.name == specialization.name,
              \.divisionStudyLevelID == specialization.divisionStudyLevelID
          ).flatMap(to: Void.self) { specialization in
            self.saveStudentStreams(specialization,
                                    admissionYears: program.admissionYears)
          }
        }
    }
  }

  private func saveStudentStreams(
    _ specialization: Specialization,
    admissionYears: [TimetableSDK.StudyLevel.AdmissionYear]
  ) -> Future<Void> {

    return admissionYears
      .serialFutureMap(on: database) { year -> Future<Void> in

        guard let studyProgramID = year.studyProgramID,
              let yearNumber = year.number else {
          return self.database.eventLoop.newSucceededFuture(result: ())
        }

        return Future.flatMap(on: self.database) {

          let studentStream = try StudentStream(
            year: yearNumber,
            timetableStudyProgramID: studyProgramID,
            specializationID: specialization.requireID()
          )

          return try studentStream.saveIfNeeded(
            on: self.database,
            conditions: \.year == studentStream.year,
                        \.specializationID == studentStream.specializationID
          ).then(self.dumpStudentStream)
        }
      }
  }

  private func dumpStudentStream(
    _ studentStream: StudentStream
  ) -> Future<Void> {

    let request = StudentGroupsRequest(
      studydyProgramID: studentStream.timetableStudyProgramID
    )

    return self.perform(request)
      .flatMap(to: Void.self) { studentGroupList in
        studentGroupList.studentGroups
          .serialFutureMap(on: self.database) {
            self.saveStudentGroup($0, studentStream: studentStream)
          }
    }
  }

  private func saveStudentGroup(
    _ timetableStudentGroup: TimetableSDK.StudentGroup,
    studentStream: StudentStream
  ) -> Future<Void> {

    guard let id = timetableStudentGroup.id,
          let name = timetableStudentGroup.name else {
      return database.eventLoop.newSucceededFuture(result: ())
    }

    return Future.flatMap(on: database) {

      let studentGroup = try StudentGroup(
        yearDependentNameFormat: nil,
        profiles: timetableStudentGroup.profiles,
        studyForm: timetableStudentGroup.studyForm,
        timetableID: id,
        timetableName: name,
        studentStreamID: studentStream.requireID()
      )

      // FIXME: Need to use upsert here!
      return try studentGroup.saveIfNeeded(
        on: self.database,
        conditions: \.timetableID == studentGroup.timetableID
      ).transform(to: ())
    }
  }

  public func dumpEducators() -> Future<Void> {

    guard #available(macOS 10.11, *) else {
      fatalError()
    }

    // Performing the request with a single emoji as a query
    // allows us to dump all the educators at once.
    let request = SearchEducatorRequest(searchQuery: "🦊")

    return perform(request).flatMap(to: Void.self) { result in
      result.educators.serialFutureMap(on: self.database) { timetableEducator in

        guard let firstName = timetableEducator.name?.givenName,
          let lastName = timetableEducator.name?.familyName,
          let id = timetableEducator.id else {
            return self.database.eventLoop.newSucceededFuture(result: ())
        }

        let educator = Educator(
          firstName: firstName,
          middleName: timetableEducator.name?.middleName,
          lastName: lastName,
          timetableID: id
        )

        return Future.flatMap(on: self.database) {
          try educator
            .saveIfNeeded(on: self.database,
                          conditions: \.timetableID == educator.timetableID)
        }.transform(to: ())
      }
    }
  }

  // MARK: - Perfroming requests

  private func perform<Request: TimetableDecodableRequestProtocol>(
    _ request: Request
  ) -> Future<Request.Result> {

    var urlComponents = baseURLComponents
    urlComponents.path = request.path
    urlComponents.queryItems = request.query.isEmpty ? nil : request.query

    let method = Vapor.HTTPMethod.RAW(value: request.method.rawValue)

    var headers = HTTPHeaders()
    headers.add(name: .accept, value: "application/json")
    headers.add(name: .acceptCharset, value: "utf-8")

    let httpRequest = HTTPRequest(method: method,
                                  url: urlComponents,
                                  headers: headers)

    let httpResponseFuture: Future<HTTPResponse>

    if let proxyPool = proxyPool {
      httpResponseFuture = proxyPool.send(httpRequest)
    } else if let client = self.client {
      httpResponseFuture = client.send(httpRequest)
    } else {
      httpResponseFuture = HTTPClient
        .connect(scheme: .https,
                 hostname: baseURLComponents.host!,
                 port: nil,
                 on: worker)
        .flatMap(to: HTTPResponse.self) { client in
          self.client = client
          return client.send(httpRequest)
      }
    }

    return httpResponseFuture.map(to: Request.Result.self) { response in
      return try Request.decodeResult(from: response)
    }
  }
}
