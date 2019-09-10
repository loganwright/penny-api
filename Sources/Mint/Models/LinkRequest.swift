import Foundation
import FluentPostgreSQL
import Vapor

public final class AccountLinkRequest: Codable {
    public var id: UUID?

    public var created: Date

    public var initiationSource: String
    public var initiationId: String

    public var requestedSource: String
    public var requestedId: String

    public var reference: String

    public init(initiationSource: String, initiationId: String, requestedSource: String, requestedId: String, reference: String) {
        self.initiationId = initiationId
        self.initiationSource = initiationSource
        self.requestedSource = requestedSource
        self.requestedId = requestedId
        self.created = Date()
        self.reference = reference
    }
}

extension AccountLinkRequest: PostgreSQLUUIDModel {
    public static let entity = "accountlinkrequests"
}
extension AccountLinkRequest: Content {}
extension AccountLinkRequest: Migration {}
extension AccountLinkRequest: Parameter {}
