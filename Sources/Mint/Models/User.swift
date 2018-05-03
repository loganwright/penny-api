
import FluentPostgreSQL
import Foundation
import Vapor

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
