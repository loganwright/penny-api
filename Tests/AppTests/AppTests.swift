import App
import Dispatch
import XCTest

@testable import App
@testable import GitHub
@testable import Vapor

final class AppTests: XCTestCase {
    func testNothing() throws {
        XCTAssert(true)
    }

    func testCreateUser() throws {
        let ghuser = try GitHub.User.get(with: app, id: "1").wait()
        let req = Request.init(using: app)
        let penny = PennyAPI.init(req)
        let user = try penny.find(ghuser).wait()
        XCTAssert(user == nil, "user not nil")
        let created = try penny.findOrCreate(ghuser).wait()
        print(created)
        let user2 = try penny.find(ghuser).wait()
        XCTAssert(user2 != nil, "didn't find created user")
    }

    static let allTests = [
        ("testNothing", testNothing)
    ]
}

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

