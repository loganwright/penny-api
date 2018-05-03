import Foundation
import Fluent
import FluentPostgreSQL

/// Access User Account Data
public struct AccountAccess {
    let worker: DatabaseWorker

    init(_ worker: DatabaseWorker) {
        self.worker = worker
    }

    // MARK: Get

    public func get(_ account: ExternalAccount) throws -> Future<Account> {
        return try get(source: account.externalSource, sourceId: account.externalId)
    }

    public func get(source: String, sourceId: String) throws -> Future<Account> {
        let existing = try search(source: source, sourceId: sourceId)
        return existing.flatMap(to: Account.self) { existing in
            if let existing = existing { return Future.map(on: self.worker) { existing } }
            return try self.create(source: source, sourceId: sourceId)
        }
    }

    // MARK: Search

    internal func search(source: String, sourceId: String) throws -> Future<Account?> {
        let filter = try QueryFilter<PostgreSQLDatabase>(
            field: .init(name: source),
            type: .equals,
            value: .data(sourceId)
        )
        let item = QueryFilterItem.single(filter)

        let query = Account.query(on: worker)
        query.addFilter(item)
        return query.first()
    }

    // MARK: Create

    internal func create(source: String, sourceId: String) throws -> Future<Account> {
        let account = Account([source: sourceId])
        guard account.sources[source] == sourceId else { throw "This source is currently unsupported: \(source)" }
        return account.save(on: worker)
    }

    // MARK: Combine Accounts

    internal func combine(_ users: [ExternalAccount]) throws -> Future<Account> {
        return try users.map(get).flatten(on: worker).flatMap(to: Account.self, combine)
    }

    internal func combine(_ accounts: [Account]) throws -> Future<Account> {
        // Must run first to avoid accidental deletes
        // accidental deletes won't lose coin records
        let sources = try accounts.combinedSources()
        let del = try delete(accounts)
        return del.then { _ in return Account(sources).save(on: self.worker) }
    }

    // MARK: Delete Accounts

    internal func delete(_ account: Account) -> Future<Void> {
        return account.delete(on: worker)
    }

    internal func delete(_ accounts: [Account]) throws -> Future<Void> {
        let ids = accounts.compactMap { $0.id }
        let query = try fetchQuery(ids: ids)
        return query.delete()
    }

    internal func fetchQuery(ids: [UUID]) throws -> QueryBuilder<Account, Account> {
        return try Account.query(on: worker).filter(\.id ~~ ids)
    }
}

extension Array where Element == Account {
    func combinedSources() throws -> [String: String] {
        var combined = [String: String]()
        try forEach { account in
            try account.sources.forEach { source, id in
                if let existing = combined[source], existing != id {
                    guard existing == id else { throw "multiple accounts found for \(source). no coins have been lost." }
                }
                combined[source] = id
            }
        }
        return combined
    }
}
