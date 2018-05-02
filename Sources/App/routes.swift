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
                print("nope")
                return Future.map(on: req) { .ok }
            }
            guard let issue = hook.issue else {
                print("nope")
                return Future.map(on: req) { .ok }
            }

            let body = hook.comment.body.trimmedWhitespace()
            if body == "fraud" {
                print("Fraud alert!")
                return Future.map(on: req) { .ok }
            } else if body != "verify" {
                let github = GitHub.API(req)
                return try github.close(issue).then { return Future.map(on: req) { .ok } }
            }

            let record = try AccountLinkRequest.fetch(
                on: req,
                requestedSource: hook.sender.externalSource,
                requestedId: hook.sender.externalId,
                reference: issue.id.description
            )

            let _ = record.flatMap(to: HTTPStatus.self) { record in
                guard let record = record else { print("No record found!"); return Future.map(on: req) { .ok } }
                struct U: ExternalUser {
                    var externalId: String
                    var externalSource: String
                }

                let one = U(externalId: record.initiationId, externalSource: record.initiationSource)
                let two = U(externalId: record.requestedId, externalSource: record.requestedSource)
                let bot = Penny.Bot(req)
                let new = try bot.user.combine([one, two])
                let coins = bot.coins.give(to: hook.sender.externalId, from: "penny", source: hook.sender.externalSource, reason: "linked github account.").flatMap(to: [Coin].self) { _ in return try bot.coins.all(for: new) }
                return coins.flatMap(to: HTTPStatus.self) { coins in
                    let value = coins.map { $0.value } .reduce(0, +)
                    let message = "Have a coin for linking your GitHub! You now have \(value) coins."
                    let github = GitHub.API(req)
                    let comment = try github.postComment(to: issue, message)
                    return comment.flatMap(to: HTTPStatus.self) { resp in
                        return try github.close(issue).flatMap(to: HTTPStatus.self) { _ in return Future.map(on: req) { .ok } }
                    }
                }
            }
            print("\(hook.sender.login) posted a comment")
            print("verified: \(hook.comment.body.trimmedWhitespace().lowercased() == "verify")")
            return Future.map(on: req) { .ok }
        }
    }

    router.get("close-issue", Int.parameter) { req -> Future<Issue> in
        let gh = GitHub.API(req)
        return try gh.postIssue(user: "penny-coin", repo: "validation", title: "Hi", body: "Delete me.").flatMap(to: Issue.self, gh.close)
    }

    router.get("users") { req -> Future<[Penny.User]> in
        return Penny.User.query(on: req).all()
    }

    router.get("links") { req -> Future<[AccountLinkRequest]> in
        return AccountLinkRequest.query(on: req).all()
    }

    router.post("gh-webhook") { req -> Future<HTTPStatus> in
        let runner = WebHookRunner(req)
        let webhook = try runner.validateWebHook(secret: "foo-bar")
        return webhook.map(runner.handle)
    }

    router.get("comment-test") { req -> Future<GitHub.Issue> in
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

    router.get("user") { req -> Future<SlackUser> in
        let slack = Slack(token: SLACK_BOT_TOKEN, worker: req)
        return try slack.getUser(id: "U1PF52H9C")
    }

    router.get("words", use: KeyGenerator.randomKey)
}
