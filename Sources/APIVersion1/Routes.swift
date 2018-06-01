//
//  Routes.swift
//  App
//
//  Created by Sergej Jaskiewicz on 16/04/2018.
//

import Vapor
import Routing
import ServerCore
import HTTP

public struct Routes {

  public static func declareRoutes(for router: Router) {

    let version = router.grouped("v1")

    let divisionsController = DivisionsController()
    version.get("divisions", use: divisionsController.allDivisions)

    version.put("divisions", "new", use: divisionsController.addDivision)
  }
}
