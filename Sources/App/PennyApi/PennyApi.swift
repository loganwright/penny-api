import Mint
import Vapor
import GitHub
import Fluent
import FluentPostgreSQL

struct CoinResponse: Content {
    let coin: Coin
    let total: Int
}

struct TotalCoinsResponse: Content {
    let total: Int
}

import Foundation

public func pennyapi(_ open: Router) throws {
    // Run through basic auth verification
    let secure = open.grouped(SimpleAuthMiddleware())

    open.get("coins") { Coin.query(on: $0).all() }
    open.get("accounts") { Account.query(on: $0).all() }
    open.get("links") { AccountLinkRequest.query(on: $0).all() }
    open.get("coins", String.parameter, String.parameter) { req -> Future<[Coin]> in
        let source = try req.parameters.next(String.self)
        let id = try req.parameters.next(String.self)

        let mint = Vault(req)
        return try mint.coins.all(source: source, sourceId: id)
    }

    // MARK: Secure Status

    secure.get("secure") { _ in "authorized" }

    // MARK: Coin Totals

    open.get("coins", String.parameter, String.parameter, "total") { req -> Future<TotalCoinsResponse> in
        let source = try req.parameters.next(String.self)
        let id = try req.parameters.next(String.self)

        let vault = Vault(req)
        return try vault.coins.total(source: source, sourceId: id).map(TotalCoinsResponse.init)
    }

    open.get("coins", "github-username", String.parameter, "total") { req -> Future<TotalCoinsResponse> in
        fatalError()
//        let username = try req.parameters.next(String.self)
//        let github = GitHub.Network(req, token: PENNY_GITHUB_TOKEN)
//        let user = try github.user(login: username)
//
//        let vault = Vault(req)
//        let total = user.flatMap(to: Int.self) { user in
//            return try vault.coins.total(source: user.externalSource, sourceId: user.externalId)
//        }
//        return total.map(TotalResponse.init)
    }

    // MARK: Post Coin

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
    }

    // MARK: Accounts

    secure.get("accounts", String.parameter, String.parameter) { req -> Future<Account> in
        let source = try req.parameters.next(String.self)
        let id = try req.parameters.next(String.self)

        let vault = Vault(req)
        return try vault.accounts.get(source: source, sourceId: id)
    }

    // MARK: Links

    
    // Submit GitHub Link Request
    secure.post("links", "github") { req -> Future<GitHubLinkResponse> in
        fatalError()
//        let pkg = try req.content.decode(GitHubLinkInput.self)
//        return pkg.flatMap(to: GitHubLinkResponse.self) { pkg in
//            return try GitHubLinkBuilder.linkGitHub(on: req, with: pkg)
//        }
    }

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
}
