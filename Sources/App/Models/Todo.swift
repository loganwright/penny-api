//import FluentSQLite
//import Vapor
import Vapor
import Foundation
import PostgreSQL
import FluentPostgreSQL

/*
 Start Postgres
 docker run --name postgres -e POSTGRES_DB=vapor   -e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password   -p 5432:5432 -d postgres
 */


/// How to merge two users

/// Slack
/// GitHub
/// Internal Reference --- how to merge back to internal user

//
/*
 coin has reference to target id, from: to:
*/
//

struct Source {
    static let slack = "slack"
    static let github = "github"
}

struct User {
    var slack: String?
    var github: String?
    // potentially more in future

    var sources: [(source: String, id: String)] {
        var list = [(source: String, id: String)]()
        if let slack = slack {
            list.append((Source.slack, slack))
        }
        if let github = github {
            list.append((Source.github, github))
        }
        return list
    }
}
///

///
/*
 Get all coins for
 */
///

struct Penny {
    func createGitHub(with req: Request) -> Future<Coin> {
        let coin = Coin(source: Source.github, to: "foo-gh", from: "bar", reason: "cuz", value: 1)
        return coin.save(on: req)
    }

    func createSlack(with req: Request) -> Future<Coin> {
        let coin = Coin(source: Source.slack, to: "foo-sl", from: "bar", reason: "cuz", value: 1)
        return coin.save(on: req)
    }

    func coins(with req: Request, for: String, usingSource source: String) throws -> Future<[Coin]> {
        // get user
        // WHERE \(source) == \(for)
        let user: User! = nil
        return try coins(with: req, for: user)
    }

    func coins(with req: Request, for user: User) throws -> Future<[Coin]> {
        let items = try user.sources.map(Coin.sourceFilter)
        let or = QueryFilterItem.group(.or, items)

        let query = Coin.query(on: req)
        query.addFilter(or)
        return query.all()
    }

    func give(coins: Int = 1, to: String, from: String, usingSource: String) {

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
