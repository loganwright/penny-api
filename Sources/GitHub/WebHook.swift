import Vapor
import Crypto

extension String: Error {}

public struct WebHook {
    public struct Payload: Content {
        public var action: String
        public struct Issue: Content {
            public var number: Int
        }
        public var issue: Issue?
        public var repository: Repo?
        public var pull_request: PullRequest?
    }

    public let event: String
    public let payload: Payload

    public static func make(with req: Request) throws -> Future<WebHook> {
        guard
            let event = req.http.headers["X-GitHub-Event"].first
            else { throw "Invalid github event." }

        let payload = try req.content.decode(Payload.self)
        return payload.map(to: WebHook.self) { payload in
            return WebHook(event: event, payload: payload)
        }
    }
}

public func validateWebHook(_ req: Request, secret: String) throws -> Future<WebHook> {
    guard
        let signature = req.http.headers["X-Hub-Signature"].first,
        let data = req.http.body.data
        else { throw "Invalid github event." }

    let digest = try HMAC.SHA1
        .authenticate(data, key: secret)
        .hexEncodedString()

    let complete = "sha1=\(digest)"
    guard complete == signature else { throw "invalid request: unauthorized" }

    return try WebHook.make(with: req)
}
