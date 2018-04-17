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

final class DivisionsController {

    func allDivisions(
        _ request: Request
    ) throws -> Future<[SPbUappModelsV1.Division]> {

        return Division.query(on: request).all()
            .map(to: [SPbUappModelsV1.Division].self) { divisions in

                let language = request.preferredLanguage

                return divisions.map { division in

                    let divisionID = DivisionID(rawValue: division.id!)

                    switch language {
                    case .en:
                        return SPbUappModelsV1
                            .Division(id: divisionID,
                                      divisionName: division
                                        .facultyNameEnglish,
                                      fieldOfStudy: division
                                        .officialDivisionNameEnglish)
                    case .ru:
                        return SPbUappModelsV1
                            .Division(id: divisionID,
                                      divisionName: division
                                        .facultyName,
                                      fieldOfStudy: division
                                        .officialDivisionName)
                    }
                }
            }
    }
}

extension SPbUappModelsV1.Division: Content {}
