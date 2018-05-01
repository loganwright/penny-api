import Routing
import Vapor
import GitHub
import Penny

import Crypto

extension GitHub.User: ExternalUser {
    public var externalId: String { return id.description }
    public var externalSource: String { return "github" }
}

extension URL {
    var queryItems: [String: String?] {
        let comps = URLComponents(url: self, resolvingAgainstBaseURL: false)

        var items = [String: String]()
        comps?.queryItems?.forEach { item in
            items[item.name] = item.value
        }
        return items
    }
}

public func routes(_ router: Router) throws {
    // I always keep a status check
    router.get("status") { req in
        return "Alive and well: \(Date())"
    }

    router.post("gh-validation-hook") { req -> Future<HTTPStatus> in
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
            guard hook.sender.externalId == hook.comment.user.externalId else {
                print("nope")
                return Future.map(on: req) { .ok }
            }

            print("\(hook.sender.login) posted a comment")
            print("verified: \(hook.comment.body.trimmedWhitespace().lowercased().contains("verify"))")
            return Future.map(on: req) { .ok }
        }
    }

    router.get("coins") { req -> EventLoopFuture<[Coin]> in
        struct CoinQuery: Content {
            let id: String
            let source: String
        }
        let query = try req.query.decode(CoinQuery.self)

        struct User: ExternalUser {
            let externalId: String
            let externalSource: String
        }
        let user = User(externalId: query.id, externalSource: query.source)

        let bot = Penny.Bot(req)
        return try bot.allCoins(for: user)
    }

    router.get("coins", "github", String.parameter) { req -> Future<[Coin]> in
        let username = try req.parameters.next(String.self)
        let user = try GitHub.User.fetch(with: req, forUsername: username)

        let bot = Penny.Bot(req)
        return user.map(bot.allCoins)
    }

    router.post("gh-webhook") { req -> Future<HTTPStatus> in
        let runner = WebHookRunner(req)
        let webhook = try runner.validateWebHook(secret: "foo-bar")
        return webhook.map(runner.handle)
    }

    router.get("comment-test") { req -> Future<Response> in
        let github = GitHub.API(req)
        let login = "loganwright"
        let slackLogin = "logan"
        var verification = "Hey there, @\(login), "
        verification += "\(slackLogin) from slack, wants to link this GitHub account."
        verification += "\n\n"
        verification += "Continue:\n"
        verification += "Comment on this issue with the word, `verify`."
        verification += "\n\n"
        verification += "**THAT'S NOT ME!**"
        verification += "Comment on this issue with the word, `fraud`."

        return try github.postIssue(user: "penny-coin", repo: "validation", title: "Verifying: \(login.lowercased())", body: verification)
    }

    router.get("words", use: KeyGenerator.randomKey)
}
