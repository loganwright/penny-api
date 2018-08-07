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
            return try client.post(baseUrl, headers: headers, content: coins).become()
        }
    }

//    func coins() throws -> Future<[Coin]> {
//        let url = baseUrl + "/coins"
//        let client = try worker.client()
//        return client.get(url, headers: baseHeaders).become()
//    }
//
//    func coins(source: String, id: String) throws -> Future<[Coin]> {
//        let url = baseUrl + "/coins/\(source)/\(id)"
//        let client = try worker.client()
//        return client.get(url, headers: baseHeaders).become()
//    }
//
//    func coinsTotal(source: String, id: String) throws -> Future<TotalCoinResponse> {
//        let url = baseUrl + "/coins/\(source)/\(id)/total"
//        let client = try worker.client()
//        return client.get(url, headers: baseHeaders).become()
//    }
}

extension Network {
//    public func postIssue(user: String, repo: String, title: String, body: String?) throws -> Future<Issue> {
//        let issueUrl = "\(baseUrl)/repos/\(user)/\(repo)/issues"
//
//        struct Post: Content {
//            let title: String
//            let body: String?
//            let labels: [String]?
//            let assignees: [String]
//        }
//
//        let post = Post(title: title, body: body, labels: ["validate"], assignees: [])
//        let client = try worker.client()
//        return client.post(issueUrl, headers: baseHeaders, content: post).become()
//    }
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

//extension Client {
//    fileprivate func post<C>(_ url: URLRepresentable, headers: HTTPHeaders = .init(), content: C) -> Future<Response> where C: Content {
//        fatalError()
////        return send(.POST, headers: headers, to: url) { try $0.content.encode(content) }
//    }
//
//    fileprivate func patch<C>(_ url: URLRepresentable, headers: HTTPHeaders = .init(), content: C) -> Future<Response> where C: Content {
//        fatalError()
////        return send(.PATCH, headers: headers, to: url) { try $0.content.encode(content) }
//    }
//}
