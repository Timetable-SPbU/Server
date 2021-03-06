import Routing
import Vapor
import APIVersion1
import ServerCore

/// Register the application's routes here.
public func routes(_ router: Router, environment: Environment) throws {

  let api = router.grouped("api")

  APIVersion1.Routes.declareRoutes(for: api)

  if !environment.isRelease {
    router.post("saveTimetable") { request -> Future<HTTPStatus> in

      let dumper = try TimetableDumper(container: request,
                                       database: request,
                                       useProxy: false)

      return dumper.dumpTimetable().map {
        return .created
      }
    }

    router.post("saveEducators") { request -> Future<HTTPStatus> in

      let dumper = try TimetableDumper(container: request,
                                       database: request,
                                       useProxy: false)

      return dumper.dumpEducators().map {
        return .created
      }
    }

    router.post("saveLocations") { request -> Future<HTTPStatus> in

      let dumper = try TimetableDumper(container: request,
                                       database: request,
                                       useProxy: false)

      return dumper.dumpLocations().map {
        return .created
      }
    }
  }
}
