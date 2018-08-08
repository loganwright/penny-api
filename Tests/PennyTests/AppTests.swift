import Dispatch
import XCTest
import Mint

@testable import Penny
@testable import Vapor

let app = try! Penny.build()

final class AppTests: XCTestCase {
    static let allTests = [
        ("testCoinLogic", testCoinLogic)
    ]

    func testCoinLogic() throws {
        let should = shouldGiftCoin(in: "@LoganWright ++\r\n")
        XCTAssertTrue(should)
    }
}

