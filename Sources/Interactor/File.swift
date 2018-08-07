import Vapor
import Mint
import App

protocol ParentNetwork {
    var baseUrl: String { get }
    var headers: HTTPHeaders { get }
    var worker: Container { get }
}

public struct Network: ParentNetwork {
    public let token: String
    public let baseUrl: String

    public let coins: CoinsAccess

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
    }

    public struct CoinsAccess {
        public let baseUrl: String

        let worker: Container
        let headers: HTTPHeaders

        public func all() throws -> Future<[Coin]> {
            let client = try worker.client()
            return client.get(baseUrl, headers: headers).become()
        }

        public func all(source: String, id: String) throws -> Future<[Coin]> {
            let url = baseUrl + "/\(source)/\(id)"
            let client = try worker.client()
            return client.get(url, headers: headers).become()
        }

        public func total(source: String, id: String) throws -> Future<TotalCoinsResponse> {
            let url = baseUrl + "/\(source)/\(id)/total"
            let client = try worker.client()
            return client.get(url, headers: headers).become()
        }

        public func add(_ coins: [Coin]) throws -> Future<[CoinResponse]> {
            let client = try worker.client()
            return client.post(baseUrl, headers: headers, content: coins).become()
        }
    }

    public struct LinkRequestsAccess {
        public let baseUrl: String

        let worker: Container
        let headers: HTTPHeaders

        public func all() throws -> Future<[AccountLinkRequest]> {
            let client = try worker.client()
            return client.get(baseUrl, headers: headers).become()
        }

        public func find(requestedSource: String, requestedId: String, reference: String) throws -> Future<AccountLinkRequest> {
            let url = baseUrl + "/\(requestedSource)/\(requestedId)/\(reference)"
            let client = try worker.client()
            return client.get(url, headers: headers).become()

        }

        public func add(_ link: AccountLinkRequest) throws -> Future<AccountLinkRequest> {
            let client = try worker.client()
            return client.post(baseUrl, headers: headers, content: link).become()
        }

        public func approve(_ link: AccountLinkRequest) throws -> Future<Account> {
            let url = baseUrl + "/approve"
            let client = try worker.client()
            return client.post(url, headers: headers, content: link).become()
        }
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
