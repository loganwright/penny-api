import Vapor
import Mint

let PENNY = "U1PF52H9C"
let MYRTLE = "U1K3D29RN"

struct MessageHandler {
    let processor = MessageProcessor()

    let worker: DatabaseWorker
    let msg: IncomingMessage
    let slack: Network
    let vault: Vault

    init(_ worker: DatabaseWorker, msg: IncomingMessage, token: String) {
        self.worker = worker
        self.msg = msg
        self.slack = Network(worker, token: token)
        self.vault = Vault(worker)
    }

    func handle() throws {
        print("Got \(msg.text) from: \(msg.user)")
        let from = msg.user

        // coin parsing
        if processor.shouldGiftCoin(in: msg.text) {
            guard msg.channel.hasPrefix("C") else { throw "public channels only" }
            let usersToGift = processor.userIdsToGift(in: msg.text, fromId: msg.user)
            try giveCoins(to: usersToGift, from: from)
        } else if msg.text.contains("<@\(MYRTLE)>") || msg.text.contains("<@\(PENNY)>") {
            if msg.text.lowercased().contains("how many") {
                try totalCoins(for: from)
            } else if msg.text.lowercased().contains("connect github") {
                try connectGitHub()
            } else if msg.text.contains("env") {
                let env = ProcessInfo.processInfo.environment["ENVIRONMENT"]
                    ?? "the void"
                try self.reply(with: "I'm in \(env)")
            }
        } else if msg.text == "!ping" {
            try self.reply(with: "pong!")
        }
    }

    func giveCoins(to: [String], from: String) throws {
        let vault = Vault(worker)

        let coins = to.map { to in
            vault.coins.give(to: to, from: from, source: "slack", reason: "twas but a gift", value: 1)
        } .flatten(on: worker)

        let pairs = coins.map(to: [(coin: Coin, total: Future<Int>)].self) { coins in
            return try coins.map { coin in
                return (coin, try vault.coins.total(source: coin.source, sourceId: coin.to))
            }
        }

        let replies = pairs.flatMap(to: [String].self) { pairs in
            return pairs.map { pair in
                return pair.total.map(to: String.self) { total in
                    return "<@\(pair.coin.to)> now has \(total) coins."
                }
            } .flatten(on: self.worker)
        }

        let reply = replies.map(to: String.self) { replies in return replies.joined(separator: "\n") }
        reply.run(self.reply)
    }

    private func reply(with reply: String) throws {
        _ = try self.slack.postComment(
            channel: msg.channel,
            text: reply,
            thread_ts: msg.thread_ts ?? msg.ts
        )
    }

    func totalCoins(for id: String) throws {
        let total = try vault.coins.total(source: "slack", sourceId: id)
        total.run { total in
            try self.reply(with: "<@\(id)> has \(total) coins.")
        }
    }

    func connectGitHub() throws {
        let components = msg.text.components(separatedBy: " ")
        guard  components.count == 4 else { throw "invalid github request format" }
        guard let githubUsername = components.last else {
            throw "invalid github connect request"
        }

        try connectGitHub(login: githubUsername, slackId: msg.user)
    }

    func connectGitHub(login: String, slackId: String) throws {
        let user = try slack.getUser(id: slackId)
        user.run { user in
            let input = GitHubLinkInput(
                githubUsername: login,
                source: "slack",
                id: self.msg.user,
                username: user.name
            )
            let linkBuilder = try GitHubLinkBuilder.linkGitHub(on: self.worker, with: input)
            linkBuilder.run { resp in
                try self.reply(with: resp.message)
            }
        }
    }
}

extension Future {
    func run(_ runner: @escaping (T) throws -> Void) {
        addAwaiter { result in
            guard let result = result.result else { return }
            do { try runner(result) }
            catch { print("SlackBot Error: \(error)") }
        }
    }
}

import Mint
import Vapor
import GitHub

struct GitHubLinkResponse: Content {
    let message: String
    let linkRequest: AccountLinkRequest
}

struct GitHubLinkInput: Content {
    let githubUsername: String
    let source: String
    let id: String
    let username: String
}

final class GitHubLinkBuilder {
    private let worker: DatabaseWorker
    private let github: GitHub.Network
    private let vault: Vault

    private let input: GitHubLinkInput

    private init(
        _ worker: DatabaseWorker,
        input: GitHubLinkInput
    ) {
        self.worker = worker
        self.github = .init(worker, token: Environment.get("PENNY_GITHUB_TOKEN")!)
        self.vault = .init(worker)

        self.input = input
    }

    private func run() throws -> Future<GitHubLinkResponse> {
        let issue = try postGitHubIssue()
        let user = try githubUser()
        return issue.and(user).flatMap(to: GitHubLinkResponse.self, makeLinkRequest)
    }

    private func postGitHubIssue() throws -> Future<GitHub.Issue> {
        var verification = "Hey there, @\(input.githubUsername), "
        verification += "\(input.username) from \(input.source), wants to link this GitHub account."
        verification += "\n\n"
        verification += "Continue:\n"
        verification += "Comment on this issue with the word, `verify`."
        verification += "\n\n"
        verification += "**THAT'S NOT ME!**\n"
        verification += "Comment on this issue with the word, `fraud`."
        verification += "\n\n"
        verification += "Something Else:\n"
        verification += "Type anything else to close this issue."

        return try github.postIssue(
            user: "penny-coin",
            repo: "validation",
            title: "Verifying: \(input.githubUsername)",
            body: verification
        )
    }

    private func githubUser() throws -> Future<GitHub.User> {
        return try github.user(login: input.githubUsername)
    }

    private func makeLinkRequest(issue: GitHub.Issue, user: GitHub.User) throws -> Future<GitHubLinkResponse> {
        let link = try vault.linkRequests.create(
            initiationSource: input.source,
            initiationId: input.id,
            requestedSource: "github",
            requestedId: user.id.description,
            reference: issue.id.description
        )

        let msg = makeMessage(issue: issue)
        return link.map { GitHubLinkResponse(message: msg, linkRequest: $0) }
    }

    private func makeMessage(issue: GitHub.Issue) -> String {
        return "Visit \(issue.html_url) to connect your GitHub account."
    }

    static func linkGitHub(on worker: DatabaseWorker, with input: GitHubLinkInput) throws -> Future<GitHubLinkResponse> {
        let worker = self.init(
            worker,
            input: input
        )
        return try worker.run()

    }
}
