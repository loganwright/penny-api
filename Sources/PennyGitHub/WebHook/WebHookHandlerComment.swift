import Vapor
import PennyConnector
import Mint
import Penny
import Foundation

extension WebHookHandler {
    internal func handleComment() throws -> Future<HTTPStatus> {
        guard hook.payload.action == "created" else { return worker.ok}
        guard let (issue, comment) = try extractComment() else { return worker.ok }
        let shouldGift = try worker.penny.messageValidator.validate(comment.body)
        return shouldGift.flatMap { shouldGift in
            guard shouldGift else { return self.worker.ok }
            return try self.process(issue: issue, comment: comment)
        }
    }

    private func process(issue: Issue, comment: Comment) throws -> Future<HTTPStatus> {
        let logins = comment.userLoginsToGift()
        let users = try self.worker.github.users(fromLogins: logins)
        return users.flatMap { users in
            let coins = comment.user.createCoins(for: users)
            return try self.worker.penny.coins.add(coins).flatMap { responses in
                let usersList = responses.formattedUsersList(users: users)
                let message = "Thanks @\(comment.user.login), I gave coins to these users:\n\n\(usersList)"
                return try self.worker.github.postComment(to: issue, message).status
            }
        }
    }

    private func extractComment() throws -> (Issue, Comment)? {
        guard
            hook.payload.action == "created",
            let issue = hook.payload.issue,
            let comment = hook.payload.comment
            else { return nil }
        return (issue, comment)
    }
}

// MARK: Extensions

extension Comment {
    fileprivate func userLoginsToGift() -> [String] {
        let from = user.login
        return body.split(separator: " ")
            .filter { $0.first == "@" }
            .map { $0.dropFirst() }
            .map { String($0) }
            .filter { $0 != from }
            .unique()
    }
}

extension User {
    fileprivate func createCoins(for users: [User]) -> [Coin] {
        return users.map { user in
            Coin(source: "github", to: user.id.description, from: self.id.description, reason: "'twas but a gift")
        }
    }
}

extension Array where Element == CoinResponse {
    fileprivate func formattedUsersList(users: [User]) -> String {
        return compactMap { response in
            return users.first(for: response.coin).flatMap { user in
                return "@\(user.login): \(response.total)"
            }
            }.joined(separator: "\n")
    }
}

extension Array where Element == User {
    fileprivate func first(for coin: Coin) -> User? {
        return first { $0.id.description == coin.to }
    }
}
