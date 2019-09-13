import Vapor
import PennyConnector
import Mint
import Penny

extension WebHookHandler {
    func handlePullRequest() throws -> Future<HTTPStatus> {
        guard let pr = extractPull() else { return worker.ok }

        let coin = Coin.pullRequestMerged(author: pr.user)
        let responses = try worker.penny.coins.add([coin])
        return responses.flatMap { responses in
            guard let response = responses.first else { return self.worker.ok }
            var msg = "Hey @\(pr.user.login), you just merged a pull request, have a coin!\n\n"
            msg += "You now have \(response.total) coins."
            return try self.worker.github.postComment(to: pr, msg).status
        }
    }

    private func extractPull() -> PullRequest? {
        guard hook.payload.action == "closed" else { return nil }
        guard let pr = hook.payload.pull_request else { return nil }
        guard pr.merged else { return nil }
        return pr
    }
}

// MARK: Extensions

extension Coin {
    fileprivate static func pullRequestMerged(author user: User) -> Coin {
        return Coin(source: "github", to: user.id.description, from: "penny", reason: "pull request: merged")
    }
}
