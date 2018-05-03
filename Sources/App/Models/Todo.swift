////import FluentSQLite
////import Vapor
//import Vapor
//import Foundation
//import PostgreSQL
//import FluentPostgreSQL
//
//struct Sauce {
//    static let slack = "slack"
//    static let github = "github"
//}
//
//final class PennyUser: Codable {
//    var id: UUID?
//
//    var slack: String?
//    var github: String?
//    // potentially more in future
//
//    init(slack: String?, github: String?) {
//        self.slack = slack
//        self.github = github
//    }
//
//    var sources: [(source: String, id: String)] {
//        var list = [(source: String, id: String)]()
//        if let slack = slack {
//            list.append((Sauce.slack, slack))
//        }
//        if let github = github {
//            list.append((Sauce.github, github))
//        }
//        return list
//    }
//}
//
//extension PennyUser {
//    convenience init(_ dict: [String: String]) {
//        self.init(
//            slack: dict[Sauce.slack],
//            github: dict[Sauce.github]
//        )
//    }
//}
//
//extension PennyUser: PostgreSQLUUIDModel {}
//extension PennyUser: Content {}
//extension PennyUser: Migration {}
//extension PennyUser: Parameter {}
//
//
/////
//
/////
///*
// Get all coins for
// */
/////
//import GitHub
//
////protocol ExternalUser {
////    var externalId: String { get }
////    var source: String { get }
////}
//
////struct PennyAPI {
////
////    let worker: Container & DatabaseConnectable
////
////    init(_ worker: Container & DatabaseConnectable) {
////        self.worker = worker
////    }
////
////    func coins(for user: ExternalUser) {
////
////    }
////}
////
////extension PennyAPI {
////    public func findOrCreate(_ externalUser: ExternalUser) throws -> Future<PennyUser> {
////        let found = try find(externalUser)
////        return found.flatMap(to: PennyUser.self) { (user) -> Future<PennyUser> in
////            if let user = user { return Future.map(on: self.worker) { user } }
////                // TODO: Get self out
////            return self.create(externalUser)
////        }
////    }
////
////    internal func find(_ externalUser: ExternalUser) throws -> Future<PennyUser?> {
////        let filter = try QueryFilter<PostgreSQLDatabase>(
////            field: .init(name: externalUser.source),
////            type: .equals,
////            value: .data(externalUser.externalId)
////        )
////        let item = QueryFilterItem.single(filter)
////
////        let query = PennyUser.query(on: worker)
////        query.addFilter(item)
////        return query.first()
////    }
////
////    internal func create(_ externalUser: ExternalUser) -> Future<PennyUser> {
////        let user = PennyUser([externalUser.source: externalUser.externalId])
////        return user.save(on: worker)
////    }
////
////    internal func combineUsers(with req: Request, users: [PennyUser]) throws -> Future<PennyUser> {
////        var allSources: [String: String] = [:]
////        users.flatMap { $0.sources } .forEach { pair in
////            // TODO: Add preventers for things like duplicate sources w/ mismatched ids
////            // this shouldn't happen unless we somehow link, for example, two github accounts
////            // with a single slack account.
////            // checks should be elsewhere also
////            allSources[pair.source] = pair.id
////        }
////
////        return users.map { $0.delete(on: req) }
////            .flatten(on: req)
////            .flatMap(to: PennyUser.self) { return PennyUser(allSources).save(on: req) }
////    }
////
//////    private func findUser(with req: Request, forSource source: String, withId id: String) throws -> Future<PennyUser?> {
//////        let filter = try QueryFilter<PostgreSQLDatabase>(
//////            field: .init(name: source),
//////            type: .equals,
//////            value: .data(id)
//////        )
//////        let item = QueryFilterItem.single(filter)
//////
//////        let query = PennyUser.query(on: req)
//////        query.addFilter(item)
//////        return query.first()
//////    }
////
////}
//
////struct Penny {
////
////    let worker: Container & DatabaseConnectable
////
////    init(_ worker: Container & DatabaseConnectable) {
////        self.worker = worker
////    }
////
////    func coins(for user: ExternalUser) {
////
////    }
////
////    func coins(with req: Request, for: String, usingSource source: String) throws -> Future<[Coin]> {
////        // get user
////        // WHERE \(source) == \(for)
////        let user: PennyUser! = nil
////        return try coins(with: req, for: user)
////    }
////
////    func coins(with req: Request, for user: PennyUser) throws -> Future<[Coin]> {
////        let items = try user.sources.map(Coin.sourceFilter)
////        let or = QueryFilterItem.group(.or, items)
////
////        let query = Coin.query(on: req)
////        query.addFilter(or)
////        return query.all()
////    }
////
////    func give(coins: Int = 1, to: String, from: String, usingSource: String) {
////
////    }
////
////    func linkSources(sourceOne: String, idOne: String, sourceTwo: String, idTwo: String) {
////
////    }
////}
////
////extension Penny {
////    func findOrCreateUser(with req: Request, forSource source: String, withId id: String) throws -> Future<PennyUser> {
////        return try findUser(with: req, forSource: source, withId: id).flatMap(to: PennyUser.self) { (user) -> Future<PennyUser> in
////            if let user = user { return Future.map(on: req) { user } }
////            else {
////                // TODO: Get self out
////                return self.createUser(with: req, forSource: source, withId: id) }
////        }
////    }
////
////    func combineUsers(with req: Request, users: [PennyUser]) throws -> Future<PennyUser> {
////        var allSources: [String: String] = [:]
////        users.flatMap { $0.sources } .forEach { pair in
////            // TODO: Add preventers for things like duplicate sources w/ mismatched ids
////            // this shouldn't happen unless we somehow link, for example, two github accounts
////            // with a single slack account.
////            // checks should be elsewhere also
////            allSources[pair.source] = pair.id
////        }
////
////        return users.map { $0.delete(on: req) }
////            .flatten(on: req)
////            .flatMap(to: PennyUser.self) { return PennyUser(allSources).save(on: req) }
////    }
////
////    private func findUser(with req: Request, forSource source: String, withId id: String) throws -> Future<PennyUser?> {
////        let filter = try QueryFilter<PostgreSQLDatabase>(
////            field: .init(name: source),
////            type: .equals,
////            value: .data(id)
////        )
////        let item = QueryFilterItem.single(filter)
////
////        let query = PennyUser.query(on: req)
////        query.addFilter(item)
////        return query.first()
////    }
////
////    private func createUser(with req: Request, forSource source: String, withId id: String) -> Future<PennyUser> {
////        let user = PennyUser([source: id])
////        return user.save(on: req)
////    }
////}
//
////extension Coin {
////    static func sourceFilter(source: String, id: String) throws -> QueryFilterItem<PostgreSQLDatabase> {
////        let sourceFilter = try QueryFilter<PostgreSQLDatabase>(
////            field: "source",
////            type: .equals,
////            value: .data(source)
////        )
////
////        let idFilter = try QueryFilter<PostgreSQLDatabase>(
////            field: "to",
////            type: .equals,
////            value: .data(id)
////        )
////
////        let source = QueryFilterItem.single(sourceFilter)
////        let id = QueryFilterItem.single(idFilter)
////        return .group(.and, [source, id])
////    }
////}
//
////final class Coin: Codable {
////    var id: UUID?
////
////    /// ie: GitHub, Slack, other future sources
////    let source: String
////    /// ie: who should receive the coin
////    /// the id here will correspond to the source
////    let to: String
////    /// ie: who gave the coin
////    /// the id here will correspond to the source, for example, if source is GitHub, it
////    /// will be a GitHub identifier
////    let from: String
////
////    /// An indication of the reason to possibly begin categorizing more
////    let reason: String?
////
////    /// The value of a given coin, for potentially allowing more coins in future
////    let value: Int
////
////    /// Date created
////    let createdAt: Date
////
////    init(source: String, to: String, from: String, reason: String?, value: Int = 1, createdAt: Date? = nil) {
////        self.source = source
////        self.to = to
////        self.from = from
////        self.reason = reason
////        self.value = value
////        self.createdAt = createdAt ?? Date()
////    }
////}
//
////extension Coin: PostgreSQLUUIDModel {}
////extension Coin: Content {}
////extension Coin: Migration {}
////extension Coin: Parameter {}
//
//
////final class CoinGift {
////    let source: String
////    let target: User
////}
//
////
/////// A single entry of a Todo list.
////final class Todo: SQLiteModel {
////    /// The unique identifier for this `Todo`.
////    var id: Int?
////
////    /// A title describing what this `Todo` entails.
////    var title: String
////
////    /// Creates a new `Todo`.
////    init(id: Int? = nil, title: String) {
////        self.id = id
////        self.title = title
////    }
////}
////
/////// Allows `Todo` to be used as a dynamic migration.
////extension Todo: Migration { }
////
/////// Allows `Todo` to be encoded to and decoded from HTTP messages.
////extension Todo: Content { }
////
/////// Allows `Todo` to be used as a dynamic parameter in route definitions.
////extension Todo: Parameter { }
//
//final class AccountLinkRequest: Codable {
//    var id: UUID?
//
//    var created: Date
//
//    var initiationId: String
//    var initiationSource: String
//
//    var requestedId: String
//    var requestedSource: String
//
//    var reference: String
//
//    init(initiationId: String, initiationSource: String, requestedId: String, requestedSource: String, reference: String) {
//        self.initiationId = initiationId
//        self.initiationSource = initiationSource
//        self.requestedSource = requestedSource
//        self.requestedId = requestedId
//        self.created = Date()
//        self.reference = reference
//    }
//}
//
//extension AccountLinkRequest {
//    static func fetch(on worker: DatabaseConnectable & Container, requestedSource: String, requestedId: String, reference: String) throws -> Future<AccountLinkRequest?> {
//        let query = AccountLinkRequest.query(on: worker)
//        let source = try QueryFilter<PostgreSQLDatabase>(
//            field: "requestedSource",
//            type: .equals,
//            value: .data(requestedSource)
//        )
//        let id = try QueryFilter<PostgreSQLDatabase>(
//            field: "requestedId",
//            type: .equals,
//            value: .data(requestedId)
//        )
//        let ref = try QueryFilter<PostgreSQLDatabase>(
//            field: "reference",
//            type: .equals,
//            value: .data(reference)
//        )
//
//        let items = [source, id, ref].map(QueryFilterItem.single)
//        let group = QueryFilterItem.group(.and, items)
//        query.addFilter(group)
//        return query.first()
//    }
//}
//
//extension AccountLinkRequest: PostgreSQLUUIDModel {}
//extension AccountLinkRequest: Content {}
//extension AccountLinkRequest: Migration {}
//extension AccountLinkRequest: Parameter {}
