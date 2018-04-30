import Foundation
import Vapor
import GitHub
import Penny

func handle(_ webhook: WebHook, on req: Request) throws -> Future<HTTPStatus> {
    guard webhook.event == "pull_request" else { return Future.map(on: req) { .ok } }

    guard let pr = webhook.payload.pull_request else { throw "expected pull request" }
    guard let repo = webhook.payload.repository else { throw "expected repository" }
    guard webhook.payload.action == "closed", pr.merged == true else { return Future.map(on: req) { .ok } }

    let repoName = repo.full_name
    let number = pr.number

    let to = pr.user.externalId
    // TODO: Should these be from the merger? Could also be from Penny's GitHub id?
    let from = "penny"
    let reason = "merged pullrequest – @\(repo.full_name)#\(pr.number)"
    let bot = Penny.Bot(req)
    return bot.coins.give(to: to, from: from, source: "github", reason: reason).flatMap(to: HTTPStatus.self) { coin in
        return try bot.user.findOrCreate(pr.user).flatMap(to: HTTPStatus.self) { user in
            return try bot.coins.all(for: user).flatMap(to: HTTPStatus.self) { coins in
                let value = coins.compactMap { $0.value } .reduce(0, +)


                var comment = "Hey @\(pr.user.login), you just merged a pull request, have a coin! "
                comment += "\n\n"
                comment += "You now have \(value) coins."
                return try GitHub.postComment(with: req, to: pr, comment).map { response in
                    response.http.status
                }
//                return try AAGitHub(req).postIssueComment(comment, fullRepoName: repoName, issue: number).flatMap(to: HTTPStatus.self) { resp in
//                    return Future.map(on: req) { resp.http.status }
//                }
            }
        }
    }
}

//func createCoin(_ req: Request) -> Future<Coin> {
//    let coin = Coin()
//    return coin.save(on: req)
//}
