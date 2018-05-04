import Routing
import Vapor
import GitHub

// TODO: Must Hide w/ Key
// Generate a new token, and use ENV_VAR
// Generate a new secret, and use ENV_VAR
let PENNY_GITHUB_TOKEN = Environment.get("PENNY_GITHUB_TOKEN")!
let GITHUB_WEBHOOK_SECRET = Environment.get("GITHUB_WEBHOOK_SECRET")!

public func routes(_ router: Router) throws {
    // I always keep a status check
    router.get("status") { req in
        return "Alive and well: \(Date())"
    }

    // Penny Endpoints
    try pennyapi(router)

    // GitHub WebHooks
    try githubapi(router)
}

func githubapi(_ router: Router) throws {
    // GitHub General Listening
    router.post("gh-webhook") { req -> Future<HTTPStatus> in
        let hook = try req.webhook(secret: "foo-bar")
        let runner = WebHookRunner(req, githubToken: PENNY_GITHUB_TOKEN)
        // Right now, only support Pull Requests, will expand
        return hook.flatMap(to: HTTPStatus.self, runner.handlePullRequest)
    }

    // GitHub Account Linking
    router.post("gh-validation-hook") { req -> Future<HTTPStatus> in
        let hook = try req.webhook(secret: nil)
        let validator = GitHubLinkValidator(req, githubToken: PENNY_GITHUB_TOKEN)
        return hook.flatMap(to: HTTPStatus.self, validator.handle)
    }
}
