import Vapor
import Mint

let GITHUB_MICROSERVICE_BASE_URL = Environment.get("GITHUB_MICROSERVICE_URL") ?? "http://localhost:9000"
let GITHUB_MICROSERVICE_KEY = Environment.get("GITHUB_MICROSERVICE_KEY") ?? "tester"

public struct GitHubLinkRequest: Content {
    public let login: String
    public let source: String
    public let sourceName: String
    public let sourceId: String

    public init(login: String, source: String, sourceName: String, sourceId: String) {
        self.login = login
        self.source = source
        self.sourceName = sourceName
        self.sourceId = sourceId
    }
}

struct GitHubConnector {
    let worker: Container
    let headers: HTTPHeaders = HTTPHeaders([
        ("Authorization", "Bearer \(GITHUB_MICROSERVICE_KEY)"),
        ("Accept", "application/json"),
        ("Content-Type", "application/json"),
    ])

    func requestLink(_ req: GitHubLinkRequest) throws -> Future<AccountLinkRequest> {
        let url = GITHUB_MICROSERVICE_BASE_URL + "/link-request"

        let client = try worker.client()
        return client.post(url, headers: headers, content: req).become()
    }
}

extension Future where T == Response {
    public func become<C: Content>(_ type: C.Type = C.self) -> Future<C> {
        return flatMap(to: C.self) { result in return try result.content.decode(C.self) }
    }
}
