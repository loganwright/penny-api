import Vapor
import Mint
import Penny

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

        let comment = Comment(body: body)
        let commentsUrl = commentable.comments_url
        let client = try worker.client()
        return client.post(commentsUrl, headers: baseHeaders, content: comment)
    }

    public func user(login: String) throws -> Future<User> {
        let url = "\(baseUrl)/users/\(login)"
        return try user(url: url)
    }

    public func user(id: String) throws -> Future<User> {
        let url = "\(baseUrl)/user/\(id)"
        return try user(url: url)
    }

    private func user(url: String) throws -> Future<User> {
        return try worker.client().get(url, headers: baseHeaders).become()
    }

    public func users(fromLogins logins: [String]) throws -> Future<[User]> {
        return try logins.map { try self.user(login: $0) }.flatten(on: self.worker)
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
    public func postValidationIssue(_ ghlr: GitHubLinkRequest) throws -> Future<Issue> {
        let title = "Verifying: \(ghlr.login)"
        let body = ghlr.verificationMessage()

        return try postIssue(
            user: GITHUB_VALIDATION_REPO_LOGIN,
            repo: GITHUB_VALIDATION_REPO_NAME,
            title: title,
            body: body
        )
    }

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

extension GitHubLinkRequest {
    func verificationMessage() -> String {
        var verification = "Hey there, @\(login), "
        verification += "`\(sourceName)` from \(source), wants to link this GitHub account."
        verification += "\n\n"
        verification += "Continue:\n"
        verification += "Comment on this issue with the word, `verify`."
        verification += "\n\n"
        verification += "**THAT'S NOT ME!**\n"
        verification += "Comment on this issue with the word, `fraud`."
        verification += "\n\n"
        verification += "Something Else:\n"
        verification += "Type anything else to close this issue."
        return verification
    }
}
