import Vapor

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
