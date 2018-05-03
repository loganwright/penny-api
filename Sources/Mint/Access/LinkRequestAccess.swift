import Foundation
import FluentPostgreSQL
import Vapor

public struct LinkRequestAccess {
    let worker: DatabaseWorker
    init(_ worker: DatabaseWorker) {
        self.worker = worker
    }

    /// Creates a new link request
    public func create(initiator: ExternalAccount, requested: ExternalAccount, reference: String) throws -> Future<AccountLinkRequest> {
        return try create(
            initiationSource: initiator.externalSource,
            initiationId: initiator.externalId,
            requestedSource: requested.externalSource,
            requestedId: requested.externalId,
            reference: reference
        )
    }

    /// Creates a new link request
    public func create(initiationSource: String, initiationId: String, requestedSource: String, requestedId: String, reference: String) throws -> Future<AccountLinkRequest> {
        let link = AccountLinkRequest(
            initiationSource: initiationSource,
            initiationId: initiationId,
            requestedSource: requestedSource,
            requestedId: requestedId,
            reference: reference
        )
        return link.save(on: worker)
    }

    /// Finds an existing link request if it exists
    public func find(requested: ExternalAccount, reference: String) throws -> Future<AccountLinkRequest?> {
        return try find(
            requestedSource: requested.externalSource,
            requestedId: requested.externalId,
            reference: reference
        )
    }

    /// Finds an existing link request if it exists
    public func find(requestedSource: String, requestedId: String, reference: String) throws -> Future<AccountLinkRequest?> {
        let query = AccountLinkRequest.query(on: worker)
        let source = try QueryFilter<PostgreSQLDatabase>(
            field: "requestedSource",
            type: .equals,
            value: .data(requestedSource)
        )
        let id = try QueryFilter<PostgreSQLDatabase>(
            field: "requestedId",
            type: .equals,
            value: .data(requestedId)
        )
        let ref = try QueryFilter<PostgreSQLDatabase>(
            field: "reference",
            type: .equals,
            value: .data(reference)
        )

        let items = [source, id, ref].map(QueryFilterItem.single)
        let group = QueryFilterItem.group(.and, items)
        query.addFilter(group)
        return query.first()
    }

    // Processes and approves the link request
    // returns the users new account
    public func approve(_ link: AccountLinkRequest) throws -> Future<Account> {
        let accounts = link.externalAccounnts
        let access = AccountAccess(worker)
        return link.delete(on: worker).flatMap(to: Account.self) { _ in try access.combine(accounts) }
    }
}

extension AccountLinkRequest {
    fileprivate var externalAccounnts: [ExternalAccount] {
        struct Account: ExternalAccount {
            let externalSource: String
            let externalId: String
        }

        let initiator = Account(externalSource: initiationSource, externalId: initiationId)
        let requested = Account(externalSource: requestedSource, externalId: requestedId)
        return [initiator, requested]
    }
}
