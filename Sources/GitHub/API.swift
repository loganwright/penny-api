import Vapor

// TODO: Must Hide w/ Key
// Generate a new token, and use ENV_VAR
// Generate a new secret, and use ENV_VAR
let ghtoken = "a3047d12ec84a96f58605df720fbda3d41f698dd"
let secret = "foo-bar"


let baseUrl = "https://api.github.com"

let baseHeaders = HTTPHeaders([
    ("Authorization", "Bearer \(ghtoken)"),
    ("Accept", "application/vnd.github.v3+json"),
])

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

public struct API {
    public let worker: Container
    public init(_ worker: Container) {
        self.worker = worker
    }

    public func postComment(to commentable: Commentable, _ body: String) throws -> Future<Response> {
        struct Comment: Content {
            let body: String
        }

        let commentsUrl = commentable.comments_url
        let comment = Comment(body: body)
        let client = try worker.make(Client.self)
        return client.post(commentsUrl, headers: baseHeaders, content: comment)
    }

    public func user(login: String) throws -> Future<User> {
        return try User.fetch(with: worker, forUsername: login)
    }
    public func user(id: String) throws -> Future<User> {
        return try User.fetch(with: worker, forId: id)
    }
}

extension API {
    public func postIssue(user: String, repo: String, title: String, body: String?) throws -> Future<Issue> {
        let issueUrl = "\(baseUrl)/repos/\(user)/\(repo)/issues"

        struct Post: Content {
            let title: String
            let body: String?
            let labels: [String]?
            let assignees: [String]
        }

        let post = Post(title: title, body: body, labels: ["validate"], assignees: [])
        let client = try worker.make(Client.self)
        return client.post(issueUrl, headers: baseHeaders, content: post).become()
    }
}

public func postComment(with worker: Container, to commentable: Commentable, _ body: String) throws -> Future<Response> {
    struct Comment: Content {
        let body: String
    }

    let commentsUrl = commentable.comments_url
    let comment = Comment(body: body)
    let client = try worker.make(Client.self)
    return client.post(commentsUrl, headers: baseHeaders, content: comment)
}
