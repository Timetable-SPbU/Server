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
      return database.future(())
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
      try studyLevel.createIfNeeded(
        on: self.database,
        conditions: \.timetableName == studyLevel.timetableName
      )
    }.flatMap(to: Void.self) { studyLevel, _ in

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
        return self.database.future(())
      }
    }
  }

  private func saveSpecializations(
    divisionStudyLevel: DivisionStudyLevel,
    programs: [TimetableSDK.StudyLevel.Program]
  ) -> Future<Void> {

    return programs
      .serialFutureMap(on: database) { program -> Future<Void> in

        guard let name = program.name else {
          // Don't process the specializatioins that don't have names —
          // it doesn't make sence.
          return self.database.future(())
        }

        let specialization = try Specialization(
          name: name,
          nameEnglish: program.englishName,
          divisionStudyLevelID: divisionStudyLevel.requireID()
        )

        return try specialization.createIfNeeded(
          on: self.database,
          conditions:
          \.name == specialization.name,
          \.divisionStudyLevelID == specialization.divisionStudyLevelID
          ).flatMap(to: Void.self) { specialization, _ in
            self.saveStudentStreams(specialization,
                                    admissionYears: program.admissionYears)
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
          return self.database.future(())
        }

        let studentStream = try StudentStream(
          year: yearNumber,
          timetableStudyProgramID: studyProgramID,
          specializationID: specialization.requireID()
        )

        return try studentStream.createIfNeeded(
          on: self.database,
          conditions: \.year == studentStream.year,
          \.specializationID == studentStream.specializationID
        ).then { self.dumpStudentStream($0.0) }
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
      return database.future(())
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

      return try studentGroup.createIfNeeded(
        on: self.database,
        conditions: \.timetableID == studentGroup.timetableID
      ).then { existingStudentGroup, created -> Future<Void> in
        if !created {
          // The student group already existed, update it.
          existingStudentGroup.timetableName = studentGroup.timetableName
          existingStudentGroup.studentStreamID = studentGroup.studentStreamID
          existingStudentGroup.studyForm = studentGroup.studyForm
          existingStudentGroup.profiles = studentGroup.profiles
          return existingStudentGroup.save(on: self.database).transform(to: ())
        } else {
          return self.database.future(())
        }
      }
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
            return self.database.future(())
        }

        let educator = Educator(
          firstName: firstName,
          middleName: timetableEducator.name?.middleName,
          lastName: lastName,
          timetableID: id
        )

        return try educator
          .createIfNeeded(on: self.database,
                          conditions: \.timetableID == educator.timetableID)
          .transform(to: ())
      }
    }
  }

  public func dumpLocations() -> Future<Void> {

    return perform(AddressesRequest()).then { addresses in

      addresses.serialFutureMap(on: self.database) {

        guard let id = ($0.id?.rawValue).map(Identifier<Address>.init),
              let name = $0.name else {
          return self.database.future(())
        }

        let address = Address(id: id, locationDescription: name)

        self.logger.debug("""
                          Fetched address "\(name)". Saving...
                          """)

        return try address
          .createIfNeeded(on: self.database, conditions: \.id == address.id)
          .then { existingAddress, created in
            if !created {
              existingAddress.locationDescription = address.locationDescription
              return existingAddress.save(on: self.database)
            } else {
              return self.database.future(existingAddress)
            }
          }.then { address in
            return self.dumpClassrooms(for: address)
          }
      }
    }
  }

  private func dumpClassrooms(for address: Address) -> Future<Void> {

    return Future
      .flatMap(on: database) { () -> Future<[TimetableSDK.Classroom]> in

        let addressID = try AddressID(rawValue: address.requireID().rawValue)
        let request = ClassroomsRequest(addressID: addressID)

        return self.perform(request)
      }.then { classrooms -> Future<Void> in
        classrooms.serialFutureMap(on: self.database) { room in

          guard let id = (room.id?.rawValue).map(Identifier<Classroom>.init),
                let name = room.name else {
            return self.database.future(())
          }

          let classroom = try Classroom(
            id: id,
            name: name,
            capacity: room.capacity,
            seating: room.seating.map(Seating.init),
            additionalInfo: room.additionalInfo,
            addressID: address.requireID()
          )

          return try classroom
            .createIfNeeded(on: self.database, conditions: \.id == classroom.id)
            .then { existingClassroom, created -> Future<Classroom> in
              if !created {
                existingClassroom.name = classroom.name
                existingClassroom.capacity = classroom.capacity
                existingClassroom.seating = classroom.seating
                existingClassroom.additionalInfo = classroom.additionalInfo
                return existingClassroom.save(on: self.database)
              } else {
                return self.database.future(existingClassroom)
              }
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
