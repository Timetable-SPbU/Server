import Routing
import Vapor
import APIVersion1

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {

    let api = router.grouped("api")

    APIVersion1.Routes.declareRoutes(for: api)
}
