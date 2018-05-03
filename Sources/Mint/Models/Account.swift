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
