import Foundation
import Vapor
import GitHub
import Mint
import Crypto

struct WebHookRunner {
    let worker: DatabaseWorker
    let githubToken: String

    private var ok: Future<HTTPStatus> { return Future.map(on: worker) { .ok } }

    init(_ worker: DatabaseWorker, githubToken: String) {
        self.worker = worker
        self.githubToken = githubToken
    }

    func handlePullRequest(_ webhook: WebHook) throws -> Future<HTTPStatus> {
        guard webhook.event == "pull_request" else { return ok }
        guard let pr = webhook.payload.pull_request else { throw "expected pull request" }
        guard let repo = webhook.payload.repository else { throw "expected repository" }
        guard webhook.payload.action == "closed", pr.merged == true else { return ok }

        let to = pr.user.externalId
        let from = "penny"
        let reason = "merged pullrequest – \(repo.full_name)#\(pr.number)"
        let source = "github"

        func makeMessage(total: Int) -> String {
            var comment = "Hey @\(pr.user.login), you just merged a pull request, have a coin! "
            comment += "\n\n"
            comment += "You now have \(total) coins."
            return comment
        }

        let vault = Vault(worker)
        let new = vault.coins.give(to: to, from: from, source: source, reason: reason)
        let total = new.flatMap(to: Int.self) { _ in try vault.coins.total(source: source, sourceId: to) }
        let message = total.map(makeMessage)

        let github = GitHub.Network(worker, token: githubToken)
        let comment = message.flatMap(to: Response.self) { message in
            return try github.postComment(to: pr, message)
        }

        return comment.map { $0.http.status }
    }
}

//
//func handle(_ webhook: WebHook, on req: Request) throws -> Future<HTTPStatus> {
//    guard webhook.event == "pull_request" else { return Future.map(on: req) { .ok } }
//
//    guard let pr = webhook.payload.pull_request else { throw "expected pull request" }
//    guard let repo = webhook.payload.repository else { throw "expected repository" }
//    guard webhook.payload.action == "closed", pr.merged == true else { return Future.map(on: req) { .ok } }
//
//    let to = pr.user.externalId
//    // TODO: Should these be from the merger? Could also be from Penny's GitHub id?
//    let from = "penny"
//    let reason = "merged pullrequest – \(repo.full_name)#\(pr.number)"
//    let source = "github"
//
//    func makeMessage(total: Int) -> String {
//        var comment = "Hey @\(pr.user.login), you just merged a pull request, have a coin! "
//        comment += "\n\n"
//        comment += "You now have \(total) coins."
//        return comment
//    }
//
//    let github = GitHub.Network(req)
//    let bot = Mint.Bot(req)
//    return bot.coins
//        .give(to: to, from: from, source: source, reason: reason)
//        .then { try bot.allCoins(for: pr.user) }
//        .map { $0.compactMap { $0.value } .reduce(0, +) }
//        .map(makeMessage)
//        .map { try github.postComment(to: pr, $0) }
//        .map { $0.http.status }
//}
//
//extension Future {
//    func then<U>(_ closure: @escaping () throws -> Future<U>) -> Future<U> {
//        return flatMap(to: U.self) { _ in try closure() }
//    }
//
//    func map<U>(_ closure: @escaping (T) throws -> Future<U>) -> Future<U> {
//        return flatMap(to: U.self, closure)
//    }
//}
