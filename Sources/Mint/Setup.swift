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
//        migrations.add(model: Coin.self, database: .psql)
        //    migrations.add(model: PennyUser.self, database: .psql)
        migrations.add(model: Mint.User.self, database: .psql)
        migrations.add(model: Mint.Coin.self, database: .psql)
        migrations.add(model: Mint.Account.self, database: .psql)
        migrations.add(model: Mint.AccountLinkRequest.self, database: .psql)
        
        print("\n\n\n\n\n******* MIGRATE ACCOUNT LINK REQUETS *******\n\n\n\n\n")
//            migrations.add(model: AccountLinkRequest.self, database: .psql)
        services.register(migrations)

        var commandConfig = CommandConfig.default()
        commandConfig.use(RevertCommand.self, as: "revert")
        services.register(commandConfig)
    }

    /// See `Provider.boot(_:)`
//    public func willBoot(_ worker: Container) throws -> Future<Void> {
//        return .done(on: worker)
//    }

    /// See `Provider.boot(_:)`
    public func didBoot(_ worker: Container) throws -> Future<Void> {
        return .done(on: worker)
    }
}

func setup(services: inout Services) {
    let databaseConfig = makeDatabaseConfig()
    let postgres = PostgreSQLDatabase(config: databaseConfig)

    var databases = DatabaseConfig()
    databases.add(database: postgres, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Coin.self, database: .psql)
//    migrations.add(model: PennyUser.self, database: .psql)
    migrations.add(model: Mint.User.self, database: .psql)
    migrations.add(model: Mint.Coin.self, database: .psql)
    print("\n\n\n\n\n******* MIGRATE ACCOUNT LINK REQUETS *******\n\n\n\n\n")
//    migrations.add(model: AccountLinkRequest.self, database: .psql)
    services.register(migrations)
}

func makeDatabaseConfig() -> PostgreSQLDatabaseConfig {
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
