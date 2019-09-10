import Routing
import Vapor

public func routes(_ router: Router) throws {
    // I always keep a status check
    router.get("status") { req in
        return "alive and well: \(Date())"
    }

    router.get("test-autodeploy") { _ in
        return "autodeploy worked :)"
    }

    // Penny Endpoints
    try pennyapi(router)
}
