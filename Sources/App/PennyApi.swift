import Mint
import Vapor
import GitHub

extension GitHub.User: Mint.ExternalAccount {
    public var externalId: String { return id.description }
    public var externalSource: String { return "github" }
}

public func pennyapi(_ router: Router) throws {
    router.get("status") { req in
        return "Alive and well: \(Date())"
    }

    // MARK: Coins

    router.get("coins") { Coin.query(on: $0).all() } // TODO: Remove in production

    router.get("coins", String.parameter, String.parameter) { req -> Future<[Coin]> in
        let source = try req.parameters.next(String.self)
        let id = try req.parameters.next(String.self)

        let mint = Vault(req)
        return try mint.coins.all(source: source, sourceId: id)
    }

    router.get("coins", "github-username", String.parameter) { req -> Future<[Coin]> in
        let username = try req.parameters.next(String.self)
        let github = GitHub.API(req)
        let user = try github.user(login: username)

        let mint = Vault(req)
        return user.flatMap(to: [Coin].self, mint.coins.all)
    }

    router.post("coins") { request -> Future<[Coin]> in
        struct Package: Content {
            let from: String
            let to: String
            let source: String
            let reason: String

            let value: Int?
        }

        let vault = Vault(request)

        let pkg = try request.content.decode(Package.self)
        let coin = pkg.flatMap(to: Coin.self) { pkg in
            vault.coins.give(to: pkg.to, from: pkg.from, source: pkg.source, reason: pkg.reason, value: pkg.value)
        }
        return vault.coins.all(for: coin)
    }

    // MARK: Accounts

    router.get("accounts") { Account.query(on: $0).all() } // TODO: Remove in production

    router.get("accounts", String.parameter, String.parameter) { req -> Future<Account> in
        let source = try req.parameters.next(String.self)
        let id = try req.parameters.next(String.self)

        let vault = Vault(req)
        return try vault.accounts.get(source: source, sourceId: id)
    }

    // MARK: Links

    // Submit Link Request
    router.post("links") { req -> Future<AccountLinkRequest> in
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
    router.get("links") { req -> Future<AccountLinkRequest> in
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
    router.post("links", "approve") { req -> Future<Account> in
        let link = try req.content.decode(AccountLinkRequest.self)

        let vault = Vault(req)
        return link.flatMap(to: Account.self, vault.linkRequests.approve)
    }
}
