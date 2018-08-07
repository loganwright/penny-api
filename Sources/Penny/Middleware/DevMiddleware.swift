import Vapor

struct DevelopmentOnlyMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        #if os(macOS)
        return try next.respond(to: request)
        #else
        return Future.map(on: request) { request.makeResponse() }
        #endif
    }
}
