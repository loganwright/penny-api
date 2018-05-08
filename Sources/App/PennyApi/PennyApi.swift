import Mint
import Vapor
import GitHub
import Fluent
import FluentPostgreSQL

struct CoinResponse: Content {
    let coin: Coin
    let total: Int
}

import Foundation


public func pennyapi(_ open: Router) throws {
    // Run through basic auth verification
    let secure = open.grouped(PennyAuthMiddleware())
    let devonly = open.grouped(DevelopmentOnlyMiddleware()).grouped("dev")

    // MARK: Development Endpoints

    open.get("fix-coins") { req -> Future<[Coin]> in
        return Coin.query(on: req).all().flatMap(to: [Coin].self) { coins in
            let discord = coins.filter { $0.source == "discord" } .filter { $0.to.hasPrefix("!") || $0.from.hasPrefix("!") }

            let fixed = discord.map { coin in
                if coin.to.hasPrefix("!") {
                    coin.to = String(coin.to.dropFirst())
                }
                if coin.from.hasPrefix("!") {
                    coin.from = String(coin.from.dropFirst())
                }
                return coin.save(on: req)
            } as [Future<Coin>]

            return fixed.flatten(on: req)
        }
    }

    open.get("fix-accounts") { req -> Future<[Account]> in
        let vault = Vault(req)

        let discordAccounts = try Account.query(on: req).filter(\.discord != nil).all()
        return discordAccounts.flatMap(to: [Account].self) { discordAccounts in
            let cleaned = discordAccounts.map { account in
                if let val = account.discord, val.hasPrefix("!") {
                    account.discord = String(val.dropFirst())
                }
                return account
            } as [Account]

            var matchedAccounts: [String: [Account]] = [:]
            for account in cleaned {
                guard let discord = account.discord else { continue }
                var accounts = matchedAccounts[discord]
                accounts?.append(account)
                matchedAccounts[discord] = accounts
            }

            let new = matchedAccounts.values.map { group in
                let new = Account(slack: nil, github: nil, discord: nil)
                group.forEach { existing in
                    if let slack = existing.slack {
                        new.slack = slack
                    }
                    if let discord = existing.discord {
                        new.discord = discord
                    }
                    if let github = existing.github {
                        new.github = github
                    }
                }
                return new
            } as [Account]

            return try vault.accounts.delete(matchedAccounts.values.flatMap { $0 }).flatMap(to: [Account].self) { _ in
                return new.map { $0.save(on: req) } .flatten(on: req)
            }
        }

//        return Coin.query(on: req).all().flatMap(to: [Coin].self) { coins in
//            let discord = coins.filter { $0.source == "discord" } .filter { $0.to.hasPrefix("!") || $0.from.hasPrefix("!") }
//
//            let fixed = discord.map { coin in
//                if coin.to.hasPrefix("!") {
//                    coin.to = String(coin.to.dropFirst())
//                }
//                if coin.from.hasPrefix("!") {
//                    coin.from = String(coin.from.dropFirst())
//                }
//                return coin.save(on: req)
//                } as [Future<Coin>]
//
//            return fixed.flatten(on: req)
//        }
    }

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

    struct TotalResponse: Content {
        let total: Int
    }

    open.get("coins", String.parameter, String.parameter, "total") { req -> Future<TotalResponse> in
        let source = try req.parameters.next(String.self)
        let id = try req.parameters.next(String.self)

        let vault = Vault(req)
        return try vault.coins.total(source: source, sourceId: id).map(TotalResponse.init)
    }

    open.get("coins", "github-username", String.parameter, "total") { req -> Future<TotalResponse> in
        let username = try req.parameters.next(String.self)
        let github = GitHub.Network(req, token: PENNY_GITHUB_TOKEN)
        let user = try github.user(login: username)

        let vault = Vault(req)
        let total = user.flatMap(to: Int.self) { user in
            return try vault.coins.total(source: user.externalSource, sourceId: user.externalId)
        }
        return total.map(TotalResponse.init)
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
        let pkg = try req.content.decode(GitHubLinkInput.self)
        return pkg.flatMap(to: GitHubLinkResponse.self) { pkg in
            return try GitHubLinkBuilder.linkGitHub(on: req, with: pkg)
        }
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
