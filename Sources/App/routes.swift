import Routing
import Vapor
import GitHub

public func routes(_ router: Router) throws {
    // I always keep a status check
    router.get("status") { req in
        return "Alive and well: \(Date())"
    }

    // Penny Endpoints
    try pennyapi(router)
}
