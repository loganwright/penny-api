import Vapor
import Foundation
import PostgreSQL
import FluentPostgreSQL

public final class Coin: Codable {
    public var id: UUID?

    /// ie: GitHub, Slack, other future sources
    public let source: String
    /// ie: who should receive the coin
    /// the id here will correspond to the source
    public let to: String
    /// ie: who gave the coin
    /// the id here will correspond to the source, for example, if source is GitHub, it
    /// will be a GitHub identifier
    public let from: String

    /// An indication of the reason to possibly begin categorizing more
    public let reason: String?

    /// The value of a given coin, for potentially allowing more coins in future
    public let value: Int

    /// Date created
    public let createdAt: Date

    public init(
        source: String,
        to: String,
        from: String,
        reason: String?,
        value: Int = 1,
        createdAt: Date? = nil
        ) {
        self.source = source
        self.to = to
        self.from = from
        self.reason = reason
        self.value = value
        self.createdAt = createdAt ?? Date()
    }
}

extension Coin: PostgreSQLUUIDModel {}
extension Coin: Content {}
extension Coin: Migration {}
extension Coin: Parameter {}
