import Foundation
import Vapor
import GitHub
import Penny

func handle(_ webhook: WebHook, on req: Request) throws -> Future<HTTPStatus> {
    guard webhook.event == "pull_request" else { return Future.map(on: req) { .ok } }

    guard let pr = webhook.payload.pull_request else { throw "expected pull request" }
    guard let repo = webhook.payload.repository else { throw "expected repository" }
    guard webhook.payload.action == "closed", pr.merged == true else { return Future.map(on: req) { .ok } }

    let to = pr.user.externalId
    // TODO: Should these be from the merger? Could also be from Penny's GitHub id?
    let from = "penny"
    let reason = "merged pullrequest – \(repo.full_name)#\(pr.number)"

    func makeMessage(total: Int) -> String {
        var comment = "Hey @\(pr.user.login), you just merged a pull request, have a coin! "
        comment += "\n\n"
        comment += "You now have \(total) coins."
        return comment
    }

    let github = GitHub.API(req)
    let bot = Penny.Bot(req)
    
    return bot.coins
        .give(to: to, from: from, source: "github", reason: reason)
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
