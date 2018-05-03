import Vapor
import FluentPostgreSQL
import Foundation

/// An account associated with the Mint.
public final class Account: Codable {
    public var id: UUID?

    // Supported external identifiers
    public var slack: String?
    public var github: String?
    public var discord: String?

    /// [SOURCE: ID]
    public var sources: [String : String] {
        var list = [String : String]()
        if let slack = slack {
            list[Sauce.slack] = slack
        }
        if let github = github {
            list[Sauce.github] = github
        }
        if let discord = discord {
            list[Sauce.discord] = discord
        }
        return list
    }

    public init(slack: String?, github: String?, discord: String?) {
        self.slack = slack
        self.github = github
        self.discord = discord
    }
}

extension Account {
    convenience init(_ dict: [String: String]) {
        self.init(
            slack: dict[Sauce.slack],
            github: dict[Sauce.github],
            discord: dict[Sauce.discord]
        )
    }
}

extension Account: PostgreSQLUUIDModel {}
extension Account: Content {}
extension Account: Migration {}
extension Account: Parameter {}

// MARK: Access

public struct AccountAccess {
    public let worker: DatabaseWorker

    public init(_ worker: DatabaseWorker) {
        self.worker = worker
    }
}

public protocol ExternalAccount {
    var externalSource: String { get }
    var externalId: String { get }
}

extension AccountAccess {
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

    internal func create(source: String, sourceId: String) throws -> Future<Account> {
        let account = Account([source: sourceId])
        guard account.sources[source] == sourceId else { throw "This source is currently unsupported: \(source)" }
        return account.save(on: worker)
    }
}

extension AccountAccess {
    public func combine(_ users: [ExternalAccount]) throws -> Future<Account> {
        return try users.map(get).flatten(on: worker).flatMap(to: Account.self, combine)
    }

    public func combine(_ accounts: [Account]) throws -> Future<Account> {
        // Must run first to avoid accidental deletes
        // accidental deletes won't lose coin records
        let sources = try! accounts.combinedSources()
        let del = try! delete(accounts)
        return del.then { _ in return Account(sources).save(on: self.worker) }
    }

    func delete(_ account: Account) -> Future<Void> {
        return account.delete(on: worker)
    }

    func delete(_ accounts: [Account]) throws -> Future<Void> {
        let ids = accounts.compactMap { $0.id }
        let query = try fetchQuery(ids: ids)
        return query.delete()
    }

    func fetchQuery(ids: [UUID]) throws -> QueryBuilder<Account, Account> {
        let ids = try ids.map { id in
                try QueryFilter<PostgreSQLDatabase>(
                    field: .init(name: "id"),
                    type: .equals,
                    value: .data(id)
                )
            }

        let queries = ids.map(QueryFilterItem.single)
        let filter = QueryFilterItem<PostgreSQLDatabase>.group(.or, queries)

        let query = Account.query(on: worker)
        query.addFilter(filter)
        return query
    }
}

extension Array where Element == Account {
    func combinedSources() throws -> [String: String] {
        var combined = [String: String]()
        try forEach { account in
            try account.sources.forEach { source, id in
                if let existing = combined[source], existing != id {
                    guard existing == id else { throw "multiple accounts found for \(source)" }
                }
                combined[source] = id
            }
        }
        return combined
    }
}




//////////



public class Accessor {
    public let worker: DatabaseWorker

    public init(_ worker: DatabaseWorker) {
        self.worker = worker
    }
}

public final class User: Codable {
    public var id: UUID?

    public var slack: String?
    public var github: String?
    public var discord: String?
    // more in future

    public init(slack: String?, github: String?, discord: String?) {
        self.slack = slack
        self.github = github
        self.discord = discord
    }

    public var sources: [String : String] {
        var list = [String : String]()
        if let slack = slack {
            list[Sauce.slack] = slack
        }
        if let github = github {
            list[Sauce.github] = github
        }
        if let discord = discord {
            list[Sauce.discord] = discord
        }
        return list
    }
}

extension User {
    convenience init(_ dict: [String: String]) {
        self.init(
            slack: dict[Sauce.slack],
            github: dict[Sauce.github],
            discord: dict[Sauce.discord]
        )
    }
}

extension User: PostgreSQLUUIDModel {}
extension User: Content {}
extension User: Migration {}
extension User: Parameter {}

