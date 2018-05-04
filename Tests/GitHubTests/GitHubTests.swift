@testable import App
import Dispatch
import XCTest
import Vapor
@testable import GitHub

let app: Application = try! App.build()

final class AppTests: XCTestCase {
    func testListRepos() throws {
    }

    static let allTests = [
        ("testListRepos", testListRepos)
    ]
}
