import Vapor
import FluentPostgreSQL
import Foundation

public final class User: Codable {
    public var id: UUID?

    public var slack: String?
    public var github: String?
    // potentially more in future

    public init(slack: String?, github: String?) {
        self.slack = slack
        self.github = github
    }

    public var sources: [String : String] {
        var list = [String : String]()
        if let slack = slack {
            list[Sauce.slack] = slack
        }
        if let github = github {
            list[Sauce.github] = github
        }
        return list
    }
}

extension User {
    convenience init(_ dict: [String: String]) {
        self.init(
            slack: dict[Sauce.slack],
            github: dict[Sauce.github]
        )
    }
}

extension User: PostgreSQLUUIDModel {}
extension User: Content {}
extension User: Migration {}
extension User: Parameter {}

