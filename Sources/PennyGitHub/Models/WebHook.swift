import Vapor
import Crypto

public struct WebHook {
    public struct Payload: Content {
        public var action: String?
        public var issue: Issue?
        public var repository: Repo?
        public var pull_request: PullRequest?
        public var comment: Comment?
        public var sender: User?
    }

    public let event: String
    public let payload: Payload
//    public let request: Request
}

extension Request {
    public func webhook(secret: String?) throws -> Future<WebHook> {
        if let secret = secret { try validate(secret: secret) }

        guard
            let event = http.headers["X-GitHub-Event"].first
            else { throw "Invalid github event." }

        let payload = try content.decode(WebHook.Payload.self)
        return payload.map(to: WebHook.self) { payload in
            return WebHook(event: event, payload: payload)
        }
    }

    private func validate(secret: String) throws {
        guard
            let signature = http.headers["X-Hub-Signature"].first,
            let data = http.body.data
            else { throw "Invalid github event." }

        let digest = try HMAC.SHA1
            .authenticate(data, key: secret)
            .hexEncodedString()

        let complete = "sha1=\(digest)"
        guard complete == signature else { throw "invalid request: unauthorized" }
    }
}
