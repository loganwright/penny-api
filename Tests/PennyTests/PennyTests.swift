import App

import Dispatch
import XCTest

import Vapor
import Crypto
import Random
@testable import Penny

final class PennyTests: XCTestCase {
    func testUserCrud() throws {
        // MARK: GitHub
        let ghe = MockExternalUser.randomGitHub()
        let github = try testUserCrud(on: ghe)
        XCTAssertEqual(github?.github, ghe.externalId)

        // MARK: Slack
        let sle = MockExternalUser.randomSlack()
        let slack = try testUserCrud(on: sle)
        XCTAssertEqual(slack?.slack, sle.externalId)

        var users = [User]()
        if let slack = slack {
            users.append(slack)
        }
        if let github = github {
            users.append(github)
        }

        // MARK: Combine
        let penny = mockPenny()
        let combined = try penny.user.combine(users).wait()
        XCTAssertEqual(combined.slack, sle.externalId)
        XCTAssertEqual(combined.github, ghe.externalId)

        // MARK: Retrieve Combined
        let one = try penny.user.findOrCreate(ghe).wait()
        let two = try penny.user.findOrCreate(sle).wait()

        let group = [one, two, combined].compactMap { $0 }
        XCTAssert(group.count == 3)

        func assertAllEqual<T: Hashable>(_ arr: [T], _ msg: String) {
            XCTAssert(Set(arr).count == 1, msg)
        }

        let ids = group.compactMap { $0.id }
        XCTAssert(ids.count == group.count, "missing at least one penny id")
        assertAllEqual(ids, "penny ids didn't match")

        let ghs = group.compactMap { $0.github }
        XCTAssert(ghs.count == group.count, "missing at least one github id")
        assertAllEqual(ghs, "github ids didn't match")

        let sls = group.compactMap { $0.slack }
        XCTAssert(sls.count == group.count, "missing at least one slack id")
        assertAllEqual(sls, "slack ids didn't match")
    }

    private func testUserCrud(on external: ExternalUser) throws -> User? {
        let penny = mockPenny()

        // MARK: Clean
        var user = try penny.user.find(external).wait()
        // In case it exists
        let _ = penny.user.delete(user)

        // MARK: Find - Fail
        user = try penny.user.find(external).wait()
        XCTAssert(user == nil, "found user that should NOT exist")

        // MARK: Create
        user = try penny.user.create(external).wait()
        XCTAssert(user != nil, "did NOT create user")

        // MARK: Find - Success
        user = try penny.user.find(external).wait()
        XCTAssert(user != nil, "did NOT find user that SHOULD exist")

        return user
    }

    func testGiveCoin() throws {
        let penny = mockPenny()

        let giver = MockExternalUser.randomGitHub()
        let receiver = MockExternalUser.randomGitHub()

        let _ = try penny.coins.give(to: receiver.externalId, from: giver.externalId, source: "github", reason: "I think you're great").wait()

        let user = try penny.user.findOrCreate(receiver).wait()
        let coins = try penny.coins.all(for: user).wait()
        XCTAssert(coins.count == 1)
    }

    static let allTests = [
        ("testUserCrud", testUserCrud),
        ("testGiveCoin", testGiveCoin),
    ]
}

func mockPenny() -> Penny.Bot {
    let response = Request(using: app)
    return Penny.Bot(response)
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

typealias MXE = MockExternalUser

struct MockExternalUser: ExternalUser {
    let externalId: String
    let externalSource: String

    static func randomGitHub() -> MockExternalUser {
        let int = try! OSRandom().generate(Int.self)
        return MockExternalUser(
            externalId: int.description,
            externalSource: "github"
        )
    }

    static func randomSlack() -> MockExternalUser {
        let uuid = UUID().uuidString
        return MockExternalUser(
            externalId: uuid,
            externalSource: "slack"
        )
    }
}
