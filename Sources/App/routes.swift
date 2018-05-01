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
            let foo: String?
        }
        let aa = try req.query.decode(CoinQuery.self)
        print(aa)
        print("")

        let query = req.http.url.queryItems
        guard
            let id = query["id"].flatMap({ $0 }),
            let source = query["source"].flatMap({$0})
            else { throw "no" }

        struct User: ExternalUser {
            let externalId: String
            let externalSource: String
        }
        let user = User(externalId: id, externalSource: source)

        let bot = Penny.Bot(req)
        return try bot.allCoins(for: user)
    }

    router.get("coins", "github", String.parameter) { req -> Future<[Coin]> in
        let username = try req.parameters.next(String.self)
        let user = try GitHub.User.fetch(with: req, forUsername: username)

        let bot = Penny.Bot(req)
        return user.flatMap(to: [Coin].self, bot.allCoins)
    }

    router.post("gh-webhook") { req -> Future<HTTPStatus> in
        return try GitHub.validateWebHook(req, secret: "foo-bar")
            .flatMap(to: HTTPStatus.self) { webhook in
                return try handle(webhook, on: req)
            }
    }

    router.get("words", use: KeyGenerator.randomKey)
}

