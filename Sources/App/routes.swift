import Routing
import Vapor
import GitHub
import Penny

import Crypto

extension GitHub.User: ExternalUser {
    public var externalId: String { return id.description }
    public var externalSource: String { return "github" }
}

extension URL {
    var queryItems: [String: String?] {
        let comps = URLComponents(url: self, resolvingAgainstBaseURL: false)

        var items = [String: String]()
        comps?.queryItems?.forEach { item in
            items[item.name] = item.value
        }
        return items
    }
}

public func routes(_ router: Router) throws {
    // I always keep a status check
    router.get("status") { req in
        return "Alive and well: \(Date())"
    }

    router.get("coins") { req -> EventLoopFuture<[Coin]> in
        struct CoinQuery: Content {
            let id: String
            let source: String
        }
        let query = try req.query.decode(CoinQuery.self)

        struct User: ExternalUser {
            let externalId: String
            let externalSource: String
        }
        let user = User(externalId: query.id, externalSource: query.source)

        let bot = Penny.Bot(req)
        return try bot.allCoins(for: user)
    }

    router.get("coins", "github", String.parameter) { req -> Future<[Coin]> in
        let username = try req.parameters.next(String.self)
        let user = try GitHub.User.fetch(with: req, forUsername: username)

        let bot = Penny.Bot(req)
        return user.map(bot.allCoins)
    }

    router.post("gh-webhook") { req -> Future<HTTPStatus> in
        return try GitHub.validateWebHook(req, secret: "foo-bar").map {webhook in
            return try handle(webhook, on: req)
        }
//            .flatMap(to: HTTPStatus.self) { webhook in
//                return try handle(webhook, on: req)
//            }
    }

    router.get("words", use: KeyGenerator.randomKey)
}

