import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "\(Date())"
    }

    router.post("gh-webhook") { req -> HTTPStatus in
        print(req)
        print("")
        return .ok
    }
    router.get("create-gh") { (req: Request) -> Future<Coin> in
        return Penny().createGitHub(with: req)
    }

    router.get("create-sl") { (req: Request) -> Future<Coin> in
        return Penny().createSlack(with: req)
    }

    router.get("list") { req in
        return Coin.query(on: req).all()
    }
    router.get("list-both") { req -> Future<[Coin]> in
        let user = User.init(slack: "foo-sl", github: "foo-gh")
        return try Penny().coins(with: req, for: user)
    }

    router.get("list-gh") { req -> Future<[Coin]> in
        let user = User.init(slack: nil, github: "foo-gh")
        return try Penny().coins(with: req, for: user)
    }

    router.get("list-sl") { req -> Future<[Coin]> in
        let user = User.init(slack: "foo-sl", github: nil)
        return try Penny().coins(with: req, for: user)
    }

    router.get("words", use: KeyGenerator.randomKey)



    // Example of configuring a controller
//    let todoController = TodoController()
//    router.get("todos", use: todoController.index)
//    router.post("todos", use: todoController.create)
//    router.delete("todos", Todo.parameter, use: todoController.delete)
}


//func createCoin(_ req: Request) -> Future<Coin> {
//    let coin = Coin()
//    return coin.save(on: req)
//}
