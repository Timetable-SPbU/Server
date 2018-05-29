//
//  DivisionsController.swift
//  APIVersion1
//
//  Created by Sergej Jaskiewicz on 17/04/2018.
//

import ServerCore
import Vapor
import Fluent
import SPbUappModelsV1

typealias DivisionViewModel = SPbUappModelsV1.Division

final class DivisionsController {

  func allDivisions(_ request: Request) throws -> Future<[DivisionViewModel]> {

    return Future.flatMap(on: request) {
      try Division.query(on: request).sort(\.id, .ascending).all()
    }.map(to: [DivisionViewModel].self) { divisions in

      let language = request.preferredLanguage

      return try divisions.map { division in

        let idRawValue = try division.requireID().rawValue
        let divisionID = DivisionID(rawValue: idRawValue)

        switch language {
        case .en:
          return DivisionViewModel(id: divisionID,
                                   divisionName: division.divisionNameEnglish,
                                   fieldOfStudy: division.fieldOfStudyEnglish,
                                   type: division.type)
        case .ru:
          return DivisionViewModel(id: divisionID,
                                   divisionName: division.divisionName,
                                   fieldOfStudy: division.fieldOfStudy,
                                   type: division.type)
        }
      }
    }
  }

  func allStudyLevels(for request: Request) throws -> Future<String> {

    let tmp = try request.parameters
      .next(Division.self)
      .flatMap(to: [StudyLevel].self) { division in
        try division.studyLevels.query(on: request).all()
      }

    fatalError()
  }
}

extension DivisionViewModel: Content {}
