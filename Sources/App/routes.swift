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


    router.get("create") { (req: Request) -> Future<Coin> in
        let coin = Coin(source: "github", to: UUID().uuidString, from: UUID().uuidString, reason: "cuz", value: 1)
        return coin.save(on: req)
    }

    router.get("list") { req -> Future<[Coin]> in
        return Coin.query(on: req).all()
    }



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
