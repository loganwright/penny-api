import Vapor

let baseUrl = "https://api.github.com"

public struct Network {
    let worker: Container
    let token: String

    let baseHeaders: HTTPHeaders

    public init(_ worker: Container, token: String) {
        self.worker = worker
        self.token = token
        self.baseHeaders = HTTPHeaders([
            ("Authorization", "Bearer \(self.token)"),
            ("Accept", "application/vnd.github.v3+json"),
        ])
    }

    public func postComment(to commentable: Commentable, _ body: String) throws -> Future<Response> {
        struct Comment: Content {
            let body: String
        }

        let commentsUrl = commentable.comments_url
        let comment = Comment(body: body)

        let client = try worker.client()
        return client.post(commentsUrl, headers: baseHeaders, content: comment)
    }

    public func user(login: String) throws -> Future<User> {
        let url = "\(baseUrl)/users/\(login)"
        return try user(url: url)
    }

    public func user(id: String) throws -> Future<User> {
        let url = "\(GitHub.baseUrl)/user/\(id)"
        return try user(url: url)
    }

    private func user(url: String) throws -> Future<User> {
        return try worker.client().get(url, headers: baseHeaders).become()
    }

    public func close(_ issue: Issue) throws -> Future<Issue> {
        struct Close: Content {
            let state: String
        }
        let close = Close(state: "closed")

        let client = try worker.make(Client.self)
        return client.patch(issue.url, headers: baseHeaders, content: close).become()
    }
}

extension Network {
    public func postIssue(user: String, repo: String, title: String, body: String?) throws -> Future<Issue> {
        let issueUrl = "\(baseUrl)/repos/\(user)/\(repo)/issues"

        struct Post: Content {
            let title: String
            let body: String?
            let labels: [String]?
            let assignees: [String]
        }

        let post = Post(title: title, body: body, labels: ["validate"], assignees: [])
        let client = try worker.client()
        return client.post(issueUrl, headers: baseHeaders, content: post).become()
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
