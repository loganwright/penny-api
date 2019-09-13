import Vapor
import Penny
import PennyConnector

/// Register your application's routes here.
public func routes(_ open: Router) throws {

    // MARK: Status

    open.get("gh-status") { _ in
        return "gh ok \(Date())"
    }
    
    // MARK: Main WebHook Feed

    open.post("github-webhook", use: WebHookHandler.handle)

    // MARK: Validation WebHook Feed

    open.post("github-validation-webhook", use: ValidationWebHookHandler.handle)

    // MARK: InterCommunication

    let secured = open.grouped(SimpleAuthMiddleware())
    secured.post("link-request", use: LinkRequestHandler.handle)
}

public func start() throws {
    try app(.detect()).run()
}
