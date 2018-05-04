import Routing
import Vapor
import GitHub

// TODO: Must Hide w/ Key
// Generate a new token, and use ENV_VAR
// Generate a new secret, and use ENV_VAR
let PENNY_GITHUB_TOKEN = Environment.get("PENNY_GITHUB_TOKEN")!

let secret = "foo-bar"

public func routes(_ router: Router) throws {
    // I always keep a status check
    router.get("status") { req in
        return "Alive and well: \(Date())"
    }

    // GitHub General Listening
    router.post("gh-webhook") { req -> Future<HTTPStatus> in
        let hook = try req.webhook(secret: "foo-bar")
        let runner = WebHookRunner(req, githubToken: PENNY_GITHUB_TOKEN)
        return hook.flatMap(to: HTTPStatus.self, runner.handlePullRequest)
    }
    // GitHub Account Linking
    router.post("gh-validation-hook", use: githubAccountLinkHook)

    // Penny Endpoints
    try pennyapi(router)
}


import GitHub
import Mint

func githubAccountLinkHook(req: Request) throws -> Future<HTTPStatus> {
    print("Validation hook: \(req)")
    //        print("VALIDATIONN: \(req)")
    struct Comment: Content {
        let body: String
        let user: GitHub.User
    }

    struct CommentHook: Content {
        let action: String
        let issue: Issue?
        let sender: GitHub.User
        let comment: Comment
    }

    let hook = try req.content.decode(CommentHook.self)
    return hook.flatMap(to: HTTPStatus.self) { hook in
        // Make sure it's the person who wrote the comment in case somebody
        // else would edit another's comment
        guard hook.sender.externalId == hook.comment.user.externalId else {
            return Future.map(on: req) { .ok }
        }
        guard let issue = hook.issue else {
            return Future.map(on: req) { .ok }
        }

        let body = hook.comment.body.trimmedWhitespace()
        if body == "fraud" {
            print("Fraud alert!")
            return Future.map(on: req) { .ok }
        } else if body != "verify" {
            let github = GitHub.Network(req, token: PENNY_GITHUB_TOKEN)
            return try github.close(issue).then { _ in return Future.map(on: req) { .ok } }
        }

        let vault = Vault(req)
        let record = try vault.linkRequests.find(requested: hook.sender, reference: issue.id.description)

        let newAccount = record.flatMap(to: Account.self) { record in
            guard let record = record else { throw "no link record found" }
            return try vault.linkRequests.approve(record)
        }
        let newCoin = vault.coins.give(
            to: hook.sender.externalId,
            from: "penny",
            source: hook.sender.externalSource,
            reason: "linked github account."
        )

        let total = newAccount.and(newCoin).flatMap(to: Int.self) { account, coin in
            try vault.coins.total(source: coin.source, sourceId: coin.to)
        }

        return total.flatMap(to: HTTPStatus.self) { total in
            let message = "Have a coin for linking your GitHub! You now have \(total) coins."
            let github = GitHub.Network(req, token: PENNY_GITHUB_TOKEN)
            let comment = try github.postComment(to: issue, message)
            return comment.flatMap(to: HTTPStatus.self) { resp in
                return try github.close(issue).flatMap(to: HTTPStatus.self) { _ in return Future.map(on: req) { .ok } }
            }
        }
    }
}

// MARK: WhiteSpace

extension String {
    internal func trimmedWhitespace() -> String {
        var characters = Substring(self)
        while characters.first?.isWhitespace == true {
            characters.removeFirst()
        }
        while characters.last?.isWhitespace == true {
            characters.removeLast()
        }

        return String(characters)
    }
}

extension Character {
    fileprivate var isWhitespace: Bool {
        switch self {
        case " ", "\t", "\n", "\r":
            return true
        default:
            return false
        }
    }
}
