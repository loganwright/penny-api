import Mint
import Vapor
import Fluent
import FluentPostgreSQL
import Foundation

public func pennyapi(_ open: Router) throws {
    // Run through basic auth verification
    let secure = open.grouped(SimpleAuthMiddleware())

    // MARK: Secure Status

    secure.get("secure") { _ in "authorized" }

    // MARK: Message Validation

    secure.post("message-validation") { req -> Future<GiftMessageResponse> in
        let message = try req.content.decode(GiftMessageRequest.self)
        return message.map { message in
            let gift = shouldGiftCoin(in: message.body)
            return GiftMessageResponse(shouldGift: gift)
        }
    }

    // MARK: Coins

    secure.get("coins") { Coin.query(on: $0).all() }

    secure.get("coins", String.parameter, String.parameter) { req -> Future<[Coin]> in
        let source = try req.parameters.next(String.self)
        let id = try req.parameters.next(String.self)

        let mint = Vault(req)
        return try mint.coins.all(source: source, sourceId: id)
    }

    secure.get("coins", String.parameter, String.parameter, "total") { req -> Future<TotalCoinsResponse> in
        let source = try req.parameters.next(String.self)
        let id = try req.parameters.next(String.self)

        let vault = Vault(req)
        return try vault.coins.total(source: source, sourceId: id).map(TotalCoinsResponse.init)
    }

    secure.post("coins") { request -> Future<[CoinResponse]> in
        let vault = Vault(request)

        let pkgs = try request.content.decode([Coin].self)
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

    // MARK: LinkRequests

    secure.get("link-requests") { AccountLinkRequest.query(on: $0).all() }

    secure.post("link-requests") { req -> Future<AccountLinkRequest> in
        let pkg = try req.content.decode(AccountLinkRequest.self)
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

    secure.get("link-requests", String.parameter, String.parameter, String.parameter) { req -> Future<AccountLinkRequest> in
        let requestedSource = try req.parameters.next(String.self)
        let requestedId = try req.parameters.next(String.self)
        let reference = try req.parameters.next(String.self)

        let vault = Vault(req)
        let found = try vault.linkRequests.find(
            requestedSource: requestedSource,
            requestedId: requestedId,
            reference: reference
        )

        return found.map(to: AccountLinkRequest.self) { found in
            guard let found = found else { throw "no record found" }
            return found
        }
    }

    secure.post("link-requests", "approve") { req -> Future<Account> in
        let link = try req.content.decode(AccountLinkRequest.self)

        let vault = Vault(req)
        return link.flatMap(to: Account.self, vault.linkRequests.approve)
    }

    // MARK: Accounts

    secure.get("accounts") { Account.query(on: $0).all() }

    secure.get("accounts", String.parameter, String.parameter) { req -> Future<Account> in
        let source = try req.parameters.next(String.self)
        let id = try req.parameters.next(String.self)

        let vault = Vault(req)
        return try vault.accounts.get(source: source, sourceId: id)
    }
}
