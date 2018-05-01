import Vapor
import Foundation
import PostgreSQL
import FluentPostgreSQL

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

        public func all(for user: Future<User>) throws -> Future<[Coin]> {
            return user.flatMap(to: [Coin].self, self.all)
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
    fileprivate static func sourceFilter(source: String, id: String) throws -> QueryFilterItem<PostgreSQLDatabase> {
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
