import Routing
import Vapor
import GitHub

struct GHWebHookResponse: Content {
    var action: String
    struct Issue: Content {
        var number: Int
    }
    var issue: Issue?
    var repository: Repo?
    var pull_request: PullRequest?
}

extension String: Error {}

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "\(Date())"
    }

    router.post("gh-webhook") { req -> Future<HTTPStatus> in
        guard let event = req.http.headers["X-GitHub-Event"].first else { throw "Invalid github event" }
        // Right now, just support PR merge.
        guard event == "pull_request" else { return Future.map(on: req) { .ok } }

        return try req.content.decode(GHWebHookResponse.self).flatMap(to: HTTPStatus.self) { webhook in
            guard let pr = webhook.pull_request else { throw "expected pull request" }
            guard let repo = webhook.repository else { throw "expected repository" }
            guard webhook.action == "closed" else { return Future.map(on: req) { .ok } }

            let repoName = repo.full_name
            let number = pr.number
            return try AAGitHub(req).postIssueComment("Hey, you just merged a pull request!", fullRepoName: repoName, issue: number).flatMap(to: HTTPStatus.self) { resp in
                return Future.map(on: req) { resp.http.status }
            }
        }

        return Future.map(on: req) { .ok }
    }

//    router.post("gh-webhook") { req -> Future<HTTPStatus> in
//        guard let event = req.http.headers["X-GitHub-Event"].first else { throw "Invalid github event" }
//        // Right now, just support PR merge.
//        guard event == "pull_request" else { return Future.map(on: req) { .ok } }
//        let action = req.content[String.self, at: "action"]
//        return action.flatMap(to: HTTPStatus.self) { action in
//            guard let action = action else { throw "Invalid github event – missing action" }
//            guard action == "closed" else { return Future.map(on: req) { .ok } }
//            return req.content[PullRequest.self, at: "pull_request"].flatMap(to: HTTPStatus.self) { pr in
//                guard let pr = pr else { throw "Expected a pull request" }
//                guard pr.merged == true else { return Future.map(on: req) { .ok } }
//                let repo = req.content[Repo.self, at: "repository"]
//                print("Repository: \(repo)")
//                print("")
//                return repo.flatMap(to: HTTPStatus.self) { repo in
//                    guard let repo = repo else { throw "expected repo" }
//                    let repoName = repo.full_name
//                    let number = pr.number
//                    return try GitHub(req).postIssueComment("Hey, you just merged a pull request!", fullRepoName: repoName, issue: number).flatMap(to: HTTPStatus.self) { resp in
//                        return Future.map(on: req) { resp.http.status }
//                    }
////                    return try GitHub(req).postComment(to: pr, "Hey, you just merged a pull request!").flatMap(to: HTTPStatus.self) { resp in
////                        return Future.map(on: req) { resp.http.status }
////                    }
//                }
//
//                // return try github.postComment(comment, issue: 1, username: "penny-coin-test-org", project: "test-00")
//
//                // to disclude owners?
//                // guard pr.author_association != "OWNER" else { return Future.map(on: req) { .ok } }
//
//                return Future.map(on: req) { .ok }
//            }
//        }
//
////        guard let action = req.content[String.self, at: "action"] else { throw "Invalid github event" }
//
//        print(req)
//        print("")
////        let event = req.http.headers["X-GitHub-Event"].first
//        print(event)
//        print("")
//        if let event = req.http.headers["X-GitHub-Event"].first, event == "issue_comment" {
//            /*
//             return try req.content.decode(Todo.self).flatMap(to: Todo.self) { todo in
//             return todo.update(on: req)
//             }
//             */
////            let resp = try req.content.decode(GHWebHookResponse.self)
////            resp.flatMap(to: HTTPStatus.self, { (re) -> EventLoopFuture<Wrapped> in
////                <#code#>
////            })
//            return try req.content.decode(GHWebHookResponse.self).flatMap(to: HTTPStatus.self) { re -> Future<HTTPStatus> in
//
//                print("got \(re)")
//                print("")
//                return try github.postComment("Hey, cool stuff, dude.", issue: re.issue.number, username: re.repository.owner.login, project: re.repository.name).flatMap(to: HTTPStatus.self) { _ in return Future.map(on: req) { .ok } }
//            }
////
////            let action = req.content[String.self, at: "action"]
////            let issueNumber = req.content[Int.self, at: "issue", "number"]
////            let project = req.content[String.self, at: "repository", "name"]
////            let username = req.content[String.self, at: "repository", "user", "login"]
////
////            print("got \(action): \(issueNumber): \(project): \(username)")
////            let _ = try github.postComment("Hey, cool stuff, dude.", issue: issueNumber, username: username, project: project)
//        }
//
//        print(req)
//        print("")
//        return Future.map(on: req) { return .ok }
//    }

    router.get("post-comment", String.parameter) { req -> Future<Response> in
        let comment = try req.parameter(String.self)
        return try github.postComment(comment, issue: 1, username: "penny-coin-test-org", project: "test-00")
    }

//    router.get("create-gh") { (req: Request) -> Future<Coin> in
//        return Penny().createGitHub(with: req)
//    }
//
//    router.get("create-sl") { (req: Request) -> Future<Coin> in
//        return Penny().createSlack(with: req)
//    }
//
//    router.get("list") { req in
//        return Coin.query(on: req).all()
//    }
//    router.get("list-both") { req -> Future<[Coin]> in
//        let user = User.init(slack: "foo-sl", github: "foo-gh")
//        return try Penny().coins(with: req, for: user)
//    }
//
//    router.get("list-gh") { req -> Future<[Coin]> in
//        let user = User.init(slack: nil, github: "foo-gh")
//        return try Penny().coins(with: req, for: user)
//    }
//
//    router.get("list-sl") { req -> Future<[Coin]> in
//        let user = User.init(slack: "foo-sl", github: nil)
//        return try Penny().coins(with: req, for: user)
//    }

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
