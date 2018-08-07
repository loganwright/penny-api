import Vapor
import Mint
import App

public struct Network {
    public let token: String
    public let baseUrl: String

    public let coins: CoinsAccess
    public let linkRequests: LinkRequestsAccess

    let worker: Container
    let headers: HTTPHeaders

    public init(_ worker: Container, baseUrl: String, token: String) {
        let headers = HTTPHeaders([
            ("Authorization", "Bearer \(token)"),
            ("Accept", "application/json"),
            ("Content-Type", "application/json"),
        ])

        self.token = token
        self.baseUrl = baseUrl
        self.worker = worker
        self.headers = headers

        self.coins = CoinsAccess(baseUrl: baseUrl + "/coins", worker: worker, headers: headers)
        self.linkRequests = LinkRequestsAccess(baseUrl: baseUrl + "/link-requests", worker: worker, headers: headers)
    }
}

extension Container {
    func client() throws -> Client {
        return try make(Client.self)
    }
}

extension Future where T == Response {
    public func become<C: Content>(_ type: C.Type = C.self) -> Future<C> {
        return flatMap(to: C.self) { result in return try result.content.decode(C.self) }
    }
}
