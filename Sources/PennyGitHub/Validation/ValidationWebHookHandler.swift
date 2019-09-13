import Vapor
import PennyConnector
import Mint
import Penny

struct ValidationWebHookHandler {
    let worker: Container
    let hook: WebHook

    let validationRepoLogin = GITHUB_VALIDATION_REPO_LOGIN
    let validationRepoName = GITHUB_VALIDATION_REPO_NAME

    func handle() throws -> Future<HTTPStatus> {
        guard let (issue, comment) = extract() else { return worker.ok }

        let body = comment.body.trimmedWhitespace()
        switch body {
        case "verify":
            return try verify(hook: hook, issue: issue, comment: comment)
        case "fraud":
            return try fraud(issue)
        case "close":
            return try close(issue)
        default:
            throw "unexpected body"
        }
    }

    private func extract() -> (Issue, Comment)? {
        guard
            hook.event == "issue_comment",
            let issue = hook.payload.issue,
            let repo = hook.payload.repository,
            repo.name == validationRepoName,
            issue.user.login == validationRepoLogin,
            let comment = hook.payload.comment,
            comment.user.login != validationRepoLogin
            else { return  nil }

        return (issue, comment)
    }

    // MARK: Responses

    private func fraud(_ issue: Issue) throws -> Future<HTTPStatus> {
        let msg = "@vapor, fraud has been reported, please address."
        return try close(issue, msg: msg)
    }

    private func close(_ issue: Issue, msg: String) throws -> Future<HTTPStatus> {
        return try worker.github.postComment(to: issue, msg).flatMap(to: HTTPStatus.self) { _ in try self.close(issue) }
    }

    private func close(_ issue: Issue) throws -> Future<HTTPStatus> {
        return try worker.github.close(issue) .flatMap(to: HTTPStatus.self) { _ in self.worker.ok }
    }

    private func verify(hook: WebHook, issue: Issue, comment: Comment) throws -> Future<HTTPStatus> {
        let link = try worker.penny.linkRequests.find(
            requestedSource: "github",
            requestedId: comment.user.id.description,
            reference: issue.number.description
        )
        return link.flatMap { link in
            let approved = try self.worker.penny.linkRequests.approve(link)
            return approved.flatMap { _ in try self.close(issue, msg: "Thanks!") }
        }
    }
}
