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
