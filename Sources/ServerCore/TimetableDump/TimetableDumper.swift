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

    public init(container: Container,
                database: DatabaseConnectable,
                useProxy: Bool) throws {
        proxyPool = useProxy ? try ProxyPool(container) : nil
        logger = try container.make(Logger.self)
        self.worker = container
        self.database = database
    }

    // MARK: - Dumping the timetable

    public func dumpTimetable() -> Future<Void> {
        return Division.query(on: database).all()
            .flatMap(to: Void.self) { divisions in
                divisions.serialFutureMap(on: self.database, self.dumpDivision)
            }
    }

    private func dumpDivision(_ division: Division) -> Future<Void> {

        let request = StudyLevelRequest(
            divisionAlias: DivisionAlias(rawValue: division.code)
        )

        return perform(request).flatMap(to: Void.self) { studyLevels in
            studyLevels.serialFutureMap(on: self.database) {
                self.saveStudyLevel(studyLevel: $0, division: division)
            }
        }
    }

    private func saveStudyLevel(
        studyLevel: TimetableSDK.StudyLevel,
        division: Division
    ) -> Future<Void> {

        guard let name = studyLevel.name else {
            // Don't process the study levels that don't have names — it doesn't
            // make sence.
            return database.eventLoop.newSucceededFuture(result: ())
        }

        let studyLevelModel = StudyLevel(name: name,
                                         nameEnglish: studyLevel.englishName,
                                         timetableName: name)

        self.logger.debug("""
        Fetched study level "\(studyLevelModel.name)". Saving…
        """)

        return Future
            .flatMap(on: database) { () -> Future<StudyLevel?> in
                try StudyLevel.query(on: self.database)
                    .filter(\.timetableName == studyLevelModel.name)
                    .first()
            }.flatMap(to: StudyLevel.self) { studyLevel in
                if let studyLevel = studyLevel {

                    self.logger.debug("""
                    Study level "\(studyLevel.name)" already exists.
                    """)

                    return self.database
                        .eventLoop
                        .newSucceededFuture(result: studyLevel)
                } else {

                    self.logger.debug("""
                    Creating study level "\(studyLevelModel.name)"…
                    """)

                    return studyLevelModel.save(on: self.database)
                }
            }.flatMap(to: Bool.self) { studyLevel in

                self.logger.debug("""
                    Creating connection betweem study level \
                    "\(studyLevelModel.name)" and \
                    division "\(division.divisionName)"
                    """)

                if studyLevel.divisionTypes.isEmpty ||
                   studyLevel.divisionTypes.contains(division.type) {
                    return division
                        .studyLevels
                        .attachIfNeeded(studyLevel, on: self.database)
                } else {
                    return self.database
                        .eventLoop
                        .newSucceededFuture(result: false)
                }
            }.transform(to: ())
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
        } else {
            httpResponseFuture = HTTPClient
                .connect(scheme: .https,
                         hostname: baseURLComponents.host!,
                         port: nil,
                         on: worker)
                .flatMap(to: HTTPResponse.self) { client in
                    client.send(httpRequest)
                }
        }

        return httpResponseFuture.map(to: Request.Result.self) { response in
            return try Request.decodeResult(from: response)
        }
    }
}
