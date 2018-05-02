import Vapor
import FluentPostgreSQL

public typealias DatabaseWorker = Container & DatabaseConnectable

extension String: Error {}

public struct Access {
    // Accessors
    public let user: UserAccess
    public let coins: Bot.CoinAccess

    // Worker
    let worker: DatabaseWorker

    public init(_ worker: Container & DatabaseConnectable) {
        self.worker = worker
        self.user = .init(worker)
        self.coins = .init(worker: worker)
    }
}

public struct Bot {
    // Accessors
    public let user: UserAccess
    public let coins: CoinAccess

    // Worker
    let worker: Container & DatabaseConnectable

    public init(_ worker: Container & DatabaseConnectable) {
        self.worker = worker
        self.user = UserAccess(worker: worker)
        self.coins = CoinAccess(worker: worker)
    }

    public func allCoins(for externalUser: ExternalUser) throws -> Future<[Coin]> {
        let user = try self.user.findOrCreate(externalUser)
        return try self.coins.all(for: user)
    }
}
