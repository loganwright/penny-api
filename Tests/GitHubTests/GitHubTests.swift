@testable import App
import Dispatch
import XCTest
import Vapor
@testable import GitHub

let app: Application = try! App.build()

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
