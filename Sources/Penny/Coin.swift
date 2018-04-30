import Vapor
import Foundation
import PostgreSQL
import FluentPostgreSQL

public final class Coin: Codable {
    public var id: UUID?

    /// ie: GitHub, Slack, other future sources
    public let source: String
    /// ie: who should receive the coin
    /// the id here will correspond to the source
    public let to: String
    /// ie: who gave the coin
    /// the id here will correspond to the source, for example, if source is GitHub, it
    /// will be a GitHub identifier
    public let from: String

    /// An indication of the reason to possibly begin categorizing more
    public let reason: String?

    /// The value of a given coin, for potentially allowing more coins in future
    public let value: Int

    /// Date created
    public let createdAt: Date

    public init(
        source: String,
        to: String,
        from: String,
        reason: String?,
        value: Int = 1,
        createdAt: Date? = nil
        ) {
        self.source = source
        self.to = to
        self.from = from
        self.reason = reason
        self.value = value
        self.createdAt = createdAt ?? Date()
    }
}

extension Coin: PostgreSQLUUIDModel {}
extension Coin: Content {}
extension Coin: Migration {}
extension Coin: Parameter {}

extension Bot {
    public struct CoinAccess {
        let worker: Container & DatabaseConnectable

        public func all(for user: User) throws -> Future<[Coin]> {
            let items = try user.sources.map(sourceFilter)
            let or = QueryFilterItem.group(.or, items)

            let query = Coin.query(on: worker)
            query.addFilter(or)
            return query.all()
        }

        public func save(_ coin: Coin) -> Future<Coin> {
            return coin.save(on: worker)
        }

        public func give(to: String, from: String, source: String, reason: String, value: Int = 1) -> Future<Coin> {
            let coin = Coin(
                source: source,
                to: to,
                from: from,
                reason: reason,
                value: value,
                createdAt: Date()
            )

            return save(coin)
        }

        private func sourceFilter(source: String, id: String) throws -> QueryFilterItem<PostgreSQLDatabase> {
            let sourceFilter = try QueryFilter<PostgreSQLDatabase>(
                field: "source",
                type: .equals,
                value: .data(source)
            )

            let idFilter = try QueryFilter<PostgreSQLDatabase>(
                field: "to",
                type: .equals,
                value: .data(id)
            )

            let source = QueryFilterItem.single(sourceFilter)
            let id = QueryFilterItem.single(idFilter)
            return .group(.and, [source, id])
        }
    }
}

extension Coin {
    static func sourceFilter(source: String, id: String) throws -> QueryFilterItem<PostgreSQLDatabase> {
        let sourceFilter = try QueryFilter<PostgreSQLDatabase>(
            field: "source",
            type: .equals,
            value: .data(source)
        )

        let idFilter = try QueryFilter<PostgreSQLDatabase>(
            field: "to",
            type: .equals,
            value: .data(id)
        )

        let source = QueryFilterItem.single(sourceFilter)
        let id = QueryFilterItem.single(idFilter)
        return .group(.and, [source, id])
    }
}
