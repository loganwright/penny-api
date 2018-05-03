import Mint
import Vapor
import GitHub

extension GitHub.User: Mint.ExternalAccount {
    public var externalId: String { return id.description }
    public var externalSource: String { return "github" }
}

let authorizedTokens: [String] = [
    "12345"
]

struct CoinResponse: Content {
    let coin: Coin
    let total: Int
}

import Foundation

struct PennyAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        guard
            let token = request.http.headers["Authorization"]
                .first?
                .components(separatedBy: "Bearer ")
                .last,
            authorizedTokens.contains(token)
            else { throw "unauthorized" }

        return try next.respond(to: request)
    }
}

public func pennyapi(_ open: Router) throws {
    // Run through basic auth verification
    let secure = open.grouped(PennyAuthMiddleware())

    // MARK: Status

    open.get("status") { req in
        return "Alive and well: \(Date())"
    }

    secure.get("secure") { _ in "authorized" }
    secure.post("secure") { req -> String in
        struct Foo: Content {
            let a: String
            let b: String
        }
        let body = try req.content.decode(Foo.self)
        print(body)
        return "authorized"
    }

    // MARK: Coins

    open.get("coins") {
        Coin.query(on: $0).all()
    } // TODO: Remove in production

    open.get("coins", String.parameter, String.parameter) { req -> Future<[Coin]> in
        let source = try req.parameters.next(String.self)
        let id = try req.parameters.next(String.self)

        let mint = Vault(req)
        return try mint.coins.all(source: source, sourceId: id)
    }

    open.get("coins", "github-username", String.parameter) { req -> Future<[Coin]> in
        let username = try req.parameters.next(String.self)
        let github = GitHub.API(req)
        let user = try github.user(login: username)

        let mint = Vault(req)
        return user.flatMap(to: [Coin].self, mint.coins.all)
    }

    secure.post("coins") { request -> Future<[CoinResponse]> in
        struct Package: Content {
            let from: String
            let to: String
            let source: String
            let reason: String

            let value: Int?
        }

        let vault = Vault(request)

        let pkgs = try request.content.decode([Package].self)
        let coins = pkgs.flatMap(to: [Coin].self) { pkgs in
            return pkgs.map { pkg in
                vault.coins.give(to: pkg.to, from: pkg.from, source: pkg.source, reason: pkg.reason, value: pkg.value)
            }.flatten(on: request)
        }

        let pairs = coins.map(to: [(coin: Coin, total: Future<Int>)].self) { coins in
            return try coins.map { coin in
                return (coin, try vault.coins.total(source: coin.source, sourceId: coin.to))
            }
        }

        return pairs.flatMap(to: [CoinResponse].self) { pairs in
            return pairs.map { pair in
                return pair.total.map(to: CoinResponse.self) { total in
                    return CoinResponse(coin: pair.coin, total: total)
                }
            } .flatten(on: request)
        }
//        let _ = coins.flatMap(to: [CoinResponse].self) { coins in
//
//            fatalError()
//        }
//
//        return coins.flatMap(to: [CoinResponse].self) { coins in
//            let totals = try coins.map { coin in
//                return (coin, try vault.coins.total(source: coin.source, sourceId: coin.to))
//            }
//            totals.flatMap(to: [CoinResponse].self) { pair in
//                pair.1.flatMap
//                fatalError()
//            }
//                fatalError()
////            return try vault.coins.total(source: coin.source, sourceId: coin.to).map { total in
////                return CoinResponse(coin: coin, total: total)
////            }
//        }

//        let coins = pkgs.map { pkg in
//            vault.coins.give(to: pkg.to, from: pkg.from, source: pkg.source, reason: pkg.reason, value: pkg.value)
//        }
//        let flat = coins.flatten(on: request)

//        let pkg = try request.content.decode(Package.self)
//        let coin = pkg.flatMap(to: Coin.self) { pkg in
//            vault.coins.give(to: pkg.to, from: pkg.from, source: pkg.source, reason: pkg.reason, value: pkg.value)
//        }
//        return coin.flatMap(to: CoinResponse.self) { coin in
//            return try vault.coins.total(source: coin.source, sourceId: coin.to).map { total in
//                return CoinResponse(coin: coin, total: total)
//            }
//        }
    }

    struct TotalResponse: Content {
        let total: Int
    }
    secure.get("coins", "total") { req -> Future<TotalResponse> in
        struct Package: Codable {
            let id: String
            let source: String
        }
        print("GOt request: \(req)")
        let pkg = try req.query.decode(Package.self)
        let vault = Vault(req)
        return try vault.coins.total(source: pkg.source, sourceId: pkg.id).map(TotalResponse.init)
    }

    // MARK: Accounts

    open.get("accounts") { Account.query(on: $0).all() } // TODO: Remove in production

    secure.get("accounts", String.parameter, String.parameter) { req -> Future<Account> in
        let source = try req.parameters.next(String.self)
        let id = try req.parameters.next(String.self)

        let vault = Vault(req)
        return try vault.accounts.get(source: source, sourceId: id)
    }

    // MARK: Links

    // Submit Link Request
    secure.post("links") { req -> Future<AccountLinkRequest> in
        struct Package: Content {
            let initiationSource: String
            let initiationId: String

            let requestedSource: String
            let requestedId: String

            let reference: String
        }

        let pkg = try req.content.decode(Package.self)
        let vault = Vault(req)
        return pkg.flatMap(to: AccountLinkRequest.self) { pkg in
            return try vault.linkRequests.create(
                initiationSource: pkg.initiationSource,
                initiationId: pkg.initiationId,
                requestedSource: pkg.requestedSource,
                requestedId: pkg.requestedId,
                reference: pkg.reference
            )
        }
    }

    // Retrieve Existing Link Request
    secure.get("links") { req -> Future<AccountLinkRequest> in
        struct Package: Content {
            let requestedSource: String
            let requestedId: String

            let reference: String
        }

        let pkg = try req.content.decode(Package.self)


        let vault = Vault(req)
        let found = pkg.flatMap(to: AccountLinkRequest?.self) { pkg in
            return try vault.linkRequests.find(
                requestedSource: pkg.requestedSource,
                requestedId: pkg.requestedId,
                reference: pkg.reference
            )
        }

        return found.map(to: AccountLinkRequest.self) { found in
            guard let found = found else { throw "no record found" }
            return found
        }
    }

    // Approve Existing Link Request
    secure.post("links", "approve") { req -> Future<Account> in
        let link = try req.content.decode(AccountLinkRequest.self)

        let vault = Vault(req)
        return link.flatMap(to: Account.self, vault.linkRequests.approve)
    }

    // Submit GitHub Link Request
    secure.post("links", "github") { req -> Future<GitHubLinkResponse> in
        let pkg = try req.content.decode(GitHubLinkInput.self)
        return pkg.flatMap(to: GitHubLinkResponse.self) { pkg in
            return try GitHubLinkWorker.linkGitHub(on: req, with: pkg)
        }
    }
}

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

final class GitHubLinkWorker {
    private let worker: DatabaseWorker
    private let github: GitHub.API
    private let vault: Vault

    private let input: GitHubLinkInput

    private init(
        _ worker: DatabaseWorker,
        input: GitHubLinkInput
    ) {
        self.worker = worker
        self.github = .init(worker)
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
            requestedSource: user.externalSource,
            requestedId: user.externalId,
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
