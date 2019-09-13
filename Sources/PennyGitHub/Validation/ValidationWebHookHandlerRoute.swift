import Vapor
import PennyConnector
import Mint
import Penny

extension ValidationWebHookHandler {
    static func handle(_ req: Request) throws -> Future<HTTPStatus> {
        let hook = try req.webhook(secret: GITHUB_VALIDATION_WEBHOOK_SECRET)
        return hook.flatMap {
            let handler = ValidationWebHookHandler(worker: req, hook: $0)
            return try handler.handle()
        }
    }
}
