import Mint
import Vapor
import GitHub

let AUTHORIZED_TOKENS: [String] = Environment.get("AUTHORIZED__ACCESS_TOKENS")!.components(separatedBy: ",")

struct PennyAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        guard
            let token = request.http.headers["Authorization"]
                .first?
                .components(separatedBy: "Bearer ")
                .last,
            AUTHORIZED_TOKENS.contains(token)
            else { throw "unauthorized" }

        return try next.respond(to: request)
    }
}
