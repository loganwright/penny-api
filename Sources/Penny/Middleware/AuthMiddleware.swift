import Vapor

private let AUTHORIZED_ACCESS_TOKENS: [String] = {
    #if os(macOS)
    return ["tester"]
    #else
    return Environment.get("AUTHORIZED_ACCESS_TOKENS")!.components(separatedBy: ",")
    #endif
}()

public struct SimpleAuthMiddleware: Middleware {
    public init() {}
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        return try next.respond(to: request)
//        guard
//            let token = request.http.headers["Authorization"]
//                .first?
//                .components(separatedBy: "Bearer ")
//                .last,
//            AUTHORIZED_ACCESS_TOKENS.contains(token)
//            else { throw "unauthorized" }
//
//        return try next.respond(to: request)
    }
}
