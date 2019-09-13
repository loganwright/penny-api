import Vapor
import PennyConnector
import Mint
import Penny

struct WebHookHandler {
    let worker: Container
    let hook: WebHook

    func handle() throws -> Future<HTTPStatus> {
        switch hook.event {
        case "pull_request":
            return try handlePullRequest()
        case "issue_comment":
            // applies to issues and pull requests (which are a type of issue)
            return try handleComment()
        default:
            // currently unsupported event
            return  worker.ok
        }
    }
}

extension Future where T == Response {
    var status: Future<HTTPStatus> {
        return map { $0.http.status }
    }
}
