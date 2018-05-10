import Vapor
import FluentPostgreSQL

/// Adds Penny's Mint to your project
public final class MintProvider: Provider {
    /// See `Provider.repositoryName`
    public static let repositoryName = "penny-mint"

    private let databaseConfig: PostgreSQLDatabaseConfig

    public init(config: PostgreSQLDatabaseConfig? = nil) {
        self.databaseConfig = config ?? makeDatabaseConfig()
    }

    /// See `Provider.register(_:)`
    public func register(_ services: inout Services) throws {
        try services.register(FluentPostgreSQLProvider())

        let postgres = PostgreSQLDatabase(config: databaseConfig)

        var databases = DatabaseConfig()
        databases.add(database: postgres, as: .psql)
        services.register(databases)

        /// Configure migrations
        var migrations = MigrationConfig()
        migrations.add(model: Mint.Coin.self, database: .psql)
        migrations.add(model: Mint.Account.self, database: .psql)
        migrations.add(model: Mint.AccountLinkRequest.self, database: .psql)
        services.register(migrations)

        var commandConfig = CommandConfig.default()
        commandConfig.use(RevertCommand.self, as: "revert")
        services.register(commandConfig)
    }


    public func didBoot(_ worker: Container) throws -> Future<Void> {
        return .done(on: worker)
    }
}

func makeDatabaseConfig() -> PostgreSQLDatabaseConfig {
    if let url = Environment.get("HEROKU_POSTGRESQL_IVORY_URL") ?? Environment.get("DATABASE_URL") {
        return try! PostgreSQLDatabaseConfig(url: url)
    }

    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    return PostgreSQLDatabaseConfig(
        hostname: hostname,
        username: username,
        database: databaseName,
        password: password
    )
}
