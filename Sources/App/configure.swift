import Vapor
import FluentPostgreSQL
import ServerCore

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router, environment: env)
    services.register(router, as: Router.self)

    let databaseProvider = FluentPostgreSQLProvider()
    try services.register(databaseProvider)

    let databaseConfig = PostgreSQLDatabaseConfig(hostname: "localhost",
                                                  port: 5432,
                                                  username: "sergej",
                                                  database: "Timetable",
                                                  password: nil)

    services.register(databaseConfig)

    var migrations = MigrationConfig()
    migrations.add(model: Division.self, database: .psql)
    migrations.add(model: StudyLevel.self, database: .psql)
    migrations.add(model: DivisionStudyLevel.self, database: .psql)
    services.register(migrations)

    let commandConfig = CommandConfig.default()
    services.register(commandConfig)
}
