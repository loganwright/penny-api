import Penny
import PennyGitHub
import Darwin
import Vapor

public func go() -> Never {
    do {
        let app = try Penny.build()
        let router = try app.make(Router.self)
        try PennyGitHub.routes(router)
        try app.run()
        exit(0)
    } catch {
        print(error)
        exit(1)
    }
}

go()
