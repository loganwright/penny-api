import Vapor
import FluentPostgreSQL

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(DateMiddleware.self) // Adds `Date` header to responses
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a Postgres database
    var databases = DatabaseConfig()
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: hostname,
        username: username,
        database: databaseName,
        password: password
    )
    let postgres = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: postgres, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Coin.self, database: .psql)
    migrations.add(model: PennyUser.self, database: .psql)
    services.register(migrations)

    var commandConfig = CommandConfig.default()
    commandConfig.use(RevertCommand.self, as: "revert")
    services.register(commandConfig)
}
