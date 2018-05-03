import Vapor
import FluentPostgreSQL

public typealias DatabaseWorker = Container & DatabaseConnectable

extension String: Error {}

public struct Vault {
    // Account Accessor
    let accounts: AccountAccess
    let coins: CoinAccess

    // Worker
    let worker: DatabaseWorker

    public init(_ worker: DatabaseWorker) {
        self.worker = worker
        self.accounts = AccountAccess(worker)
        self.coins = CoinAccess(worker)
    }
}
