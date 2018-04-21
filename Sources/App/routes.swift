import Routing
import Vapor
import APIVersion1
import ServerCore

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router, environment: Environment) throws {

    let api = router.grouped("api")

    APIVersion1.Routes.declareRoutes(for: api)

    if !environment.isRelease {
        router.post("saveStudyLevels") { request -> Future<HTTPStatus> in

            let dumper = try TimetableDumper(container: request,
                                             database: request,
                                             useProxy: false)

            return dumper.dumpTimetable().map(to: HTTPStatus.self) {
                return .ok
            }
        }
    }
}
