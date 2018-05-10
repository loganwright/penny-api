import App
import Dispatch
import XCTest
import Mint

@testable import App
@testable import GitHub
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

    func testCreateUser() throws {
        var table = [String: Int]()

        originalCoinTable.split(separator: "\n").map { $0.split(separator: "|").map { $0.trimWhitespace() } }.forEach { pair in
            let id = String(pair[0])
            let value = Int(String(pair[1]))!

            var existing = table[id] ?? 0
            existing += value
            table[id] = existing
        }

        let coins = table.map { to, val -> Coin in
            return Coin(source: "slack", to: to, from: "transfer", reason: "penny-slack-transfer")
        }

        print(coins)
        print("")
//        let ghuser = try GitHub.User.get(with: app, id: "1").wait()
//        let req = Request.init(using: app)
//        let penny = PennyAPI.init(req)
//        let user = try penny.find(ghuser).wait()
//        XCTAssert(user == nil, "user not nil")
//        let created = try penny.findOrCreate(ghuser).wait()
//        print(created)
//        let user2 = try penny.find(ghuser).wait()
//        XCTAssert(user2 != nil, "didn't find created user")
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

