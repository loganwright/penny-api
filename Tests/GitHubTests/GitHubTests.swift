import App
import Dispatch
import XCTest

func _postGHComment(with req: Request) throws {
    var headers = GitHub.baseHeaders
    // /repos/:owner/:repo/issues/:number/comments
    let commentURL = "https://api.github.com/repos/LoganWright/penny-test-repository/issues/1/comments"
    struct Comment: Content {
        let body: String
    }

    let comment = Comment(body: "Hello, from the api!")
    let client = try req.make(Client.self)
    let send = client.post(commentURL, headers: headers, content: comment)

    //    let send = client.send(.GET, to: comps.url!)
    send.catch { error in
        print(error)
    }

    let _ = send.map { resp -> String in
        let url = resp.content[String.self, at: "url"]

        print(resp)
        print()
        return "hi"
    }
}

import Vapor
@testable import GitHub

func getRepos(worker: Application, forOrg org: String) throws -> [Repo] {
    let url = "https://api.github.com/orgs/\(org)/repos"

    let client = try worker.make(Client.self)
    let send = client.get(url, headers: GitHub.baseHeaders)
    let result = try send.wait()
//    print(result.content)
    let repos = try result.content.decode([Repo].self).wait()
    print(repos)
    print("")
    return []
//    var headers = GitHub.baseHeaders
//    // /repos/:owner/:repo/issues/:number/comments
//    struct Comment: Content {
//        let body: String
//    }
//
//    let comment = Comment(body: "Hello, from the api!")
//    let client = try req.make(Client.self)
//    let send = client.post(commentURL, headers: headers, content: comment)
//
//    //    let send = client.send(.GET, to: comps.url!)
//    send.catch { error in
//        print(error)
//    }
//
//    let _ = send.map { resp -> String in
//        let url = resp.content[String.self, at: "url"]
//
//        print(resp)
//        print()
//        return "hi"
//    }
}

let testApp: Application = {
    var config = Config.default()
    var env = try! Environment.detect()
    var services = Services.default()

    try! App.configure(&config, &env, &services)

    let app = try! Application(
        config: config,
        environment: env,
        services: services
    )

    try! App.boot(app)

    return app
}()

final class AppTests: XCTestCase {
    func testNothing() throws {
        XCTAssert(true)
        let repos = try getRepos(worker: testApp, forOrg: "penny-coin-test-org")
    }

    static let allTests = [
        ("testNothing", testNothing)
    ]
}
