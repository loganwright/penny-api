//import Mint
//import Vapor
//import GitHub
//
//public func pennyapi(_ router: Router) throws {
//    router.get("status") { req in
//        return "Alive and well: \(Date())"
//    }
//
//    // MARK: Coins
//    router.get("coins") { req -> Future<[Coin]> in
//        struct CoinQuery: Content, ExternalUser {
//            let id: String
//            let source: String
//
//            var externalId: String { return id }
//            var externalSource: String { return source }
//        }
//        let query = try req.query.decode(CoinQuery.self)
//
//        let bot = Mint.Bot(req)
//        return try bot.allCoins(for: query)
//    }
//
//    router.get("coins", "github", String.parameter) { req -> Future<[Coin]> in
//        let username = try req.parameters.next(String.self)
//        let user = try GitHub.User.fetch(with: req, forUsername: username)
//
//        let bot = Mint.Bot(req)
//        return user.map(bot.allCoins)
//    }
//}
