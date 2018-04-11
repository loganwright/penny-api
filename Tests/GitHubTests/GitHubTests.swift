import App
import Dispatch
import XCTest
import Vapor
@testable import GitHub

let app: Application = {
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
    func testListRepos() throws {
        let org = try Repo.list(with: app, forOrg: "penny-coin-test-org").wait()
        XCTAssert(org.count > 0)
        let user = try Repo.list(with: app, forUserName: "LoganWright").wait()
        XCTAssert(user.count > 0)
    }

    static let allTests = [
        ("testListRepos", testListRepos)
    ]
}
