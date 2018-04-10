//import FluentSQLite
//import Vapor
import Vapor
import Foundation
import PostgreSQL
import FluentPostgreSQL

/// How to merge two users

/// Slack
/// GitHub
/// Internal Reference --- how to merge back to internal user

//
/*
 coin has reference to target id, from: to:
*/
//

struct User {
    var id: String?

    var slackId: String?
    var githubId: String?
}
///

struct Penny {
    func give(coins: Int = 1, to: String, from: String, usingSource: String) {

    }
}

struct InternalUser {
    var id: String?
}

struct SlackUser {

}

struct GitHubUser {

}

struct ExternalUser {
    let source: String
    let internalUserId: String
}

struct __Coin {
    var id: UUID?

    /// ie: GitHub, Slack, other future sources
    var source: String
    /// ie: who should receive the coin
    /// the id here will correspond to the source
    var receiver: String
    /// ie: who gave the coin
    /// the id here will correspond to the source, for example, if source is GitHub, it
    /// will be a GitHub identifier
    var giver: String

    /// An indication of the reason to possibly begin categorizing more
    var reason: String?

    /// The value of a given coin, for potentially allowing more coins in future
    var value: Int = 1
}

final class Coin: Codable {
    var id: UUID?

    /// ie: GitHub, Slack, other future sources
    var source: String
    /// ie: who should receive the coin
    /// the id here will correspond to the source
    var to: String
    /// ie: who gave the coin
    /// the id here will correspond to the source, for example, if source is GitHub, it
    /// will be a GitHub identifier
    var from: String

    /// An indication of the reason to possibly begin categorizing more
    var reason: String?

    /// The value of a given coin, for potentially allowing more coins in future
    var value: Int = 1

    init(source: String, to: String, from: String, reason: String?, value: Int) {
        self.source = source
        self.to = to
        self.from = from
        self.reason = reason
        self.value = value
    }
}

extension Coin: PostgreSQLUUIDModel {}
extension Coin: Content {}
extension Coin: Migration {}
extension Coin: Parameter {}


//final class CoinGift {
//    let source: String
//    let target: User
//}

//
///// A single entry of a Todo list.
//final class Todo: SQLiteModel {
//    /// The unique identifier for this `Todo`.
//    var id: Int?
//
//    /// A title describing what this `Todo` entails.
//    var title: String
//
//    /// Creates a new `Todo`.
//    init(id: Int? = nil, title: String) {
//        self.id = id
//        self.title = title
//    }
//}
//
///// Allows `Todo` to be used as a dynamic migration.
//extension Todo: Migration { }
//
///// Allows `Todo` to be encoded to and decoded from HTTP messages.
//extension Todo: Content { }
//
///// Allows `Todo` to be used as a dynamic parameter in route definitions.
//extension Todo: Parameter { }
