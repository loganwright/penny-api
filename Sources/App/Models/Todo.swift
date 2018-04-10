//import FluentSQLite
//import Vapor
import Vapor
import Foundation
import PostgreSQL
import FluentPostgreSQL

struct Penny {
    func give(coins: Int = 1, to: String, from: String, usingSource: String) {

    }
}

struct InternalUser {
    let id: String
}

struct SlackUser {

}

struct ExternalUser {
    let source: String
    let internalUserId: String
}

final class Coin: Codable {
    var id: UUID?
    init() {
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
