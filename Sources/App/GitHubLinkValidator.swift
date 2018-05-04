import Mint
import Vapor
import GitHub

struct GitHubLinkValidator {
    private let worker: DatabaseWorker
    private let github: GitHub.Network
    private let vault: Vault

    private let githubToken: String

    private var ok: Future<HTTPStatus> { return Future.map(on: worker) { .ok } }

    init(_ worker: DatabaseWorker, githubToken: String) {
        self.worker = worker
        self.github = .init(worker, token: githubToken)
        self.vault = .init(worker)

        self.githubToken = githubToken
    }

    func handle(_ hook: WebHook) -> Future<HTTPStatus> {
        // GH WebHook expects a status indicating WebHook Health,
        // It doesn't care about anything else w/ webhook data
        do { return try self.route(hook) }
        catch { return self.ok }
    }

    private func route(_ hook: WebHook) throws -> Future<HTTPStatus> {
        let (issue, comment) = try verify(hook)

        let body = hook.payload.comment?.body
            .trimmedWhitespace()
            .lowercased()
            ?? ""

        switch body {
        case "verify":
            return try verify(hook: hook, issue: issue, comment: comment)
        case "fraud":
            return try fraud(issue)
        case "close":
            return try close(issue)
        default:
            throw "unexpected body"
        }
    }

    private func verify(_ hook: WebHook) throws -> (Issue, GitHub.Comment) {
        guard
            let sender = hook.payload.sender,
            let comment = hook.payload.comment,
            let issue = hook.payload.issue
            else { throw "invalid" }

        // Make sure sender of hook is author of comment
        // (avoid edits from other users, ie: admins)
        guard sender.id == comment.user.id else { throw "invalid" }

        return (issue, comment)
    }

    private func verify(hook: WebHook, issue: Issue, comment: GitHub.Comment) throws -> Future<HTTPStatus> {
        let record = try vault
            .linkRequests
            .find(requested: comment.user, reference: issue.id.description)

        let newAccount = record.flatMap(to: Account.self) { record in
            guard let record = record else { throw "no link record found" }
            return try self.vault.linkRequests.approve(record)
        }
        let newCoin = vault.coins.give(
            to: comment.user.externalId,
            from: "penny",
            source: comment.user.externalSource,
            reason: "linked github account"
        )

        let total = newAccount.and(newCoin).flatMap(to: Int.self) { account, coin in
            try self.vault.coins.total(source: coin.source, sourceId: coin.to)
        }

        return total.flatMap(to: HTTPStatus.self) { total in
            let msg = "Have a coin for linking your GitHub! You now have \(total) coins."
            return try self.close(issue, msg: msg)
        }
    }

    private func fraud(_ issue: Issue) throws -> Future<HTTPStatus> {
        let msg = "@loganwright, fraud has been reported, please address."
        return try close(issue, msg: msg)
    }

    private func close(_ issue: Issue) throws -> Future<HTTPStatus> {
        return try github.close(issue).flatMap(to: HTTPStatus.self) { _ in self.ok }
    }
    
    private func close(_ issue: Issue, msg: String) throws -> Future<HTTPStatus> {
        let comment = try self.github.postComment(to: issue, msg)
        return comment.flatMap(to: HTTPStatus.self) { _ in try self.close(issue) }
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

