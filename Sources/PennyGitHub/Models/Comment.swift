import Vapor

public struct Comment: Content {
    public let body: String
    public let user: User
}
