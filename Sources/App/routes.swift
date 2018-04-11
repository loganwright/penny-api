import Routing
import Vapor

struct GHWebHookResponse: Content {
    var action: String
    struct Issue: Content {
        var number: Int
    }
    var issue: Issue
    struct Repo: Content {
        var name: String

        struct Owner: Content {
            var login: String
        }
        var owner: Owner
    }
    var repository: Repo
}

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "\(Date())"
    }

    router.post("gh-webhook") { req -> Future<HTTPStatus> in
        print(req)
        print("")
        let event = req.http.headers["X-GitHub-Event"].first
        print(event)
        print("")
        if let event = req.http.headers["X-GitHub-Event"].first, event == "issue_comment" {
            /*
             return try req.content.decode(Todo.self).flatMap(to: Todo.self) { todo in
             return todo.update(on: req)
             }
             */
//            let resp = try req.content.decode(GHWebHookResponse.self)
//            resp.flatMap(to: HTTPStatus.self, { (re) -> EventLoopFuture<Wrapped> in
//                <#code#>
//            })
            return try req.content.decode(GHWebHookResponse.self).flatMap(to: HTTPStatus.self) { re -> Future<HTTPStatus> in

                print("got \(re)")
                print("")
                return try github.postComment("Hey, cool stuff, dude.", issue: re.issue.number, username: re.repository.owner.login, project: re.repository.name).flatMap(to: HTTPStatus.self) { _ in return Future.map(on: req) { .ok } }
            }
//
//            let action = req.content[String.self, at: "action"]
//            let issueNumber = req.content[Int.self, at: "issue", "number"]
//            let project = req.content[String.self, at: "repository", "name"]
//            let username = req.content[String.self, at: "repository", "user", "login"]
//
//            print("got \(action): \(issueNumber): \(project): \(username)")
//            let _ = try github.postComment("Hey, cool stuff, dude.", issue: issueNumber, username: username, project: project)
        }

        print(req)
        print("")
        return Future.map(on: req) { return .ok }
    }

    router.get("post-comment", String.parameter) { req -> Future<Response> in
        let comment = try req.parameter(String.self)
        return try github.postComment(comment, issue: 1, username: "penny-coin-test-org", project: "test-00")
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
