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
    return Division.query(on: request).sort(\.id, .ascending).all()
      .map { divisions in

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

  func addDivision(_ request: Request) throws -> Future<HTTPStatus> {

    return try request.content.decode(ServerCore.Division.self)
      .then { division in
        division.create(on: request)
      }.map { _ in
        .created
      }
  }
}

extension DivisionViewModel: Content {}
