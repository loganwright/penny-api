import Vapor
import Foundation
import PostgreSQL
import FluentPostgreSQL

public struct CoinAccess {

    let worker: DatabaseWorker

    init(_ worker: DatabaseWorker) {
        self.worker = worker
    }

    public func all(for account: ExternalAccount) throws -> Future<[Coin]> {
        return try all(source: account.externalSource, sourceId: account.externalId)
    }

    public func all(source: String, sourceId: String) throws -> Future<[Coin]> {
        let access = AccountAccess(worker)
        let account = try access.get(source: source, sourceId: sourceId)
        return all(for: account)
    }

    public func all(for user: Future<Account>) -> Future<[Coin]> {
        return user.flatMap(to: [Coin].self, self.all)
    }

    public func all(for account: Account) throws -> Future<[Coin]> {
        let filters = try account.sources.map(sourceFilter)
        // TODO: Improve to use fewer req's, by combining w/ `||` and making single database req
        return filters.map { $0.all() } .flatten(on: worker) .map { coins in return coins.flatMap { $0 } }
    }


    public func all(for coin: Future<Coin>) -> Future<[Coin]> {
        return coin.flatMap(to: [Coin].self, all)
    }

    public func all(for coin: Coin) throws -> Future<[Coin]> {
        return try all(source: coin.source, sourceId: coin.to)
    }

    // TODO: Optimize
    public func total(source: String, sourceId: String) throws -> Future<Int> {
        return try all(source: source, sourceId: sourceId).map(to: Int.self) { coins in
            return coins.map { $0.value } .reduce(0, +)
        }
    }

    public func give(to: String, from: String, source: String, reason: String, value: Int? = nil) -> Future<Coin> {
        let coin = Coin(
            source: source,
            to: to,
            from: from,
            reason: reason,
            value: value ?? 1,
            createdAt: Date()
        )

        return save(coin)
    }

    internal func save(_ coin: Coin) -> Future<Coin> {
        return coin.save(on: worker)
    }

    private func sourceFilter(source: String, id: String) throws -> QueryBuilder<PostgreSQLDatabase, Coin> {
        return Coin.query(on: worker)
            .filter(.column(nil, .identifier("source")), .equal, source)
            .filter(.column(nil, .identifier("to")), .equal, id)
    }
}
