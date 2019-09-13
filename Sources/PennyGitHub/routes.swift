import Vapor
import Penny
import PennyConnector

/// Register your application's routes here.
public func routes(_ open: Router) throws {

    // MARK: Status

    open.get("status") { _ in return "Ok \(Date())" }

    // MARK: Main WebHook Feed

    open.post("github-webhook", use: WebHookHandler.handle)

    // MARK: Validation WebHook Feed

    open.post("github-validation-webhook", use: ValidationWebHookHandler.handle)

    // MARK: InterCommunication

    let secured = open.grouped(SimpleAuthMiddleware())
    secured.post("link-request", use: LinkRequestHandler.handle)
}
