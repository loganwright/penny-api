import App
import Dispatch
import XCTest
import Mint

@testable import App
@testable import Vapor

/* private but tests */ internal extension Character {
    var isASCIIWhitespace: Bool {
        return self == " " || self == "\t" || self == "\r" || self == "\n" || self == "\r\n"
    }
}

/* private but tests */ internal extension String {
    func trimASCIIWhitespace() -> Substring {
        return self.dropFirst(0).trimWhitespace()
    }
}

private extension Substring {
    func trimWhitespace() -> Substring {
        var me = self
        while me.first?.isASCIIWhitespace == .some(true) {
            me = me.dropFirst()
        }
        while me.last?.isASCIIWhitespace == .some(true) {
            me = me.dropLast()
        }
        return me
    }
}

final class AppTests: XCTestCase {
    func testNothing() throws {
        XCTAssert(true)
    }

    static let allTests = [
        ("testNothing", testNothing)
    ]
}

let app = try! App.build()

