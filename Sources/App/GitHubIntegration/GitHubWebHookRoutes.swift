import Vapor

let GITHUB_GENERAL_WEBHOOK_SECRET = Environment.get("GITHUB_GENERAL_WEBHOOK_SECRET")!
let GITHUB_VALIDATION_WEBHOOK_SECRET = Environment.get("GITHUB_VALIDATION_WEBHOOK_SECRET")!

func githubapi(_ router: Router) throws {
    // GitHub General Listening
    router.post("gh-webhook") { req -> Future<HTTPStatus> in
        let hook = try req.webhook(secret: GITHUB_GENERAL_WEBHOOK_SECRET)
        let runner = WebHookRunner(req, githubToken: PENNY_GITHUB_TOKEN)
        // Right now, only support Pull Requests, will expand
        return hook.flatMap(to: HTTPStatus.self, runner.handlePullRequest)
    }

    // GitHub Account Linking
    router.post("gh-validation-hook") { req -> Future<HTTPStatus> in
        let hook = try req.webhook(secret: GITHUB_VALIDATION_WEBHOOK_SECRET)
        let validator = GitHubLinkValidator(req, githubToken: PENNY_GITHUB_TOKEN)
        return hook.flatMap(to: HTTPStatus.self, validator.handle)
    }
}
