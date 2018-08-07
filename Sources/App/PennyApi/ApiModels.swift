import Mint
import Vapor
import Fluent
import FluentPostgreSQL

public struct CoinResponse: Content {
    public let coin: Coin
    public let total: Int
}

public struct TotalCoinsResponse: Content {
    public let total: Int
}
