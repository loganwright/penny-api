import Foundation
import Vapor
import GitHub
import Penny
import Crypto

struct WebHookRunner {
    let req: Request
    init(_ req: Request) {
        self.req = req
    }

    public func validateWebHook(secret: String) throws -> Future<WebHook> {
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

    func handle(_ webhook: WebHook) throws -> Future<HTTPStatus> {
        guard webhook.event == "pull_request" else { return Future.map(on: req) { .ok } }

        guard let pr = webhook.payload.pull_request else { throw "expected pull request" }
        guard let repo = webhook.payload.repository else { throw "expected repository" }
        guard webhook.payload.action == "closed", pr.merged == true else { return Future.map(on: req) { .ok } }

        let to = pr.user.externalId
        // TODO: Should these be from the merger? Could also be from Penny's GitHub id?
        let from = "penny"
        let reason = "merged pullrequest – \(repo.full_name)#\(pr.number)"
        let source = "github"

        func makeMessage(total: Int) -> String {
            var comment = "Hey @\(pr.user.login), you just merged a pull request, have a coin! "
            comment += "\n\n"
            comment += "You now have \(total) coins."
            return comment
        }

        let github = GitHub.API(req)
        let bot = Penny.Bot(req)
        return bot.coins
            .give(to: to, from: from, source: source, reason: reason)
            .then { try bot.allCoins(for: pr.user) }
            .map { $0.compactMap { $0.value } .reduce(0, +) }
            .map(makeMessage)
            .map { try github.postComment(to: pr, $0) }
            .map { $0.http.status }
    }
}

func handle(_ webhook: WebHook, on req: Request) throws -> Future<HTTPStatus> {
    guard webhook.event == "pull_request" else { return Future.map(on: req) { .ok } }

    guard let pr = webhook.payload.pull_request else { throw "expected pull request" }
    guard let repo = webhook.payload.repository else { throw "expected repository" }
    guard webhook.payload.action == "closed", pr.merged == true else { return Future.map(on: req) { .ok } }

    let to = pr.user.externalId
    // TODO: Should these be from the merger? Could also be from Penny's GitHub id?
    let from = "penny"
    let reason = "merged pullrequest – \(repo.full_name)#\(pr.number)"
    let source = "github"

    func makeMessage(total: Int) -> String {
        var comment = "Hey @\(pr.user.login), you just merged a pull request, have a coin! "
        comment += "\n\n"
        comment += "You now have \(total) coins."
        return comment
    }

    let github = GitHub.API(req)
    let bot = Penny.Bot(req)
    return bot.coins
        .give(to: to, from: from, source: source, reason: reason)
        .then { try bot.allCoins(for: pr.user) }
        .map { $0.compactMap { $0.value } .reduce(0, +) }
        .map(makeMessage)
        .map { try github.postComment(to: pr, $0) }
        .map { $0.http.status }
}

extension Future {
    func then<U>(_ closure: @escaping () throws -> Future<U>) -> Future<U> {
        return flatMap(to: U.self) { _ in try closure() }
    }

    func map<U>(_ closure: @escaping (T) throws -> Future<U>) -> Future<U> {
        return flatMap(to: U.self, closure)
    }
}
