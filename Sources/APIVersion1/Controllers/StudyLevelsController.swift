//
//  StudyLevelsController.swift
//  APIVersion1
//
//  Created by Sergej Jaskiewicz on 19/04/2018.
//

import ServerCore
import Vapor
import Fluent
import SPbUappModelsV1

final class StudyLevelsController {

    func allStudyLevels(for request: Request) throws -> Future<String> {

        let tmp = try request
            .parameter(Division.self)
            .flatMap(to: [StudyLevel].self) { division in
                try division.studyLevels.query(on: request).all()
            }

        fatalError()
    }
}
