import Vapor
import FluentPostgreSQL
import ServerCore

/// Called before the application initializes.
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
                                                username: "sergej",
                                                database: "TimetableTest",
                                                password: nil)

  services.register(databaseConfig)

  services.register(MigrationConfig.addAllMigrations())

  var commandConfig = CommandConfig.default()
  commandConfig.useFluentCommands()
  services.register(commandConfig)
}
