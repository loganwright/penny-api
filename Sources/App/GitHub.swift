import Vapor
import Foundation
import HTTP
import WebSocket

let ghtoken = "a3047d12ec84a96f58605df720fbda3d41f698dd"

struct GitHub {
    static let baseUrl = "https://api.github.com"
    static let baseHeaders = HTTPHeaders(
        [
            ("Authorization", "Bearer \(ghtoken)"),
            ("Accept", "application/vnd.github.v3+json"),
        ]
    )

    let app: Application

    func postComment(_ body: String, issue: Int, username: String, project: String) throws -> Future<Response> {
        let headers = GitHub.baseHeaders
        // /repos/:owner/:repo/issues/:number/comments
        let commentURL = "\(GitHub.baseUrl)/repos/\(username)/\(project)/issues/\(issue)/comments"
        //"https://api.github.com/repos/LoganWright/penny-test-repository/issues/1/comments"
        //"https://api.github.com/repos/penny-coin-test-org/test-00/issues/1/comments"
        //"\(GitHub.baseUrl)/repos/\(username)/\(project)/issues/\(issue)/comments"

        struct Comment: Content {
            let body: String
        }

        let comment = Comment(body: body)
        let client = try app.make(Client.self)
        let send = client.post(commentURL, headers: headers, content: comment)
        return send.map { resp -> Response in
//            let url = resp.content[String.self, at: "url"]
            print(resp)
            print()
            return resp
        }
    }

    func updateComment(_ body: String, commentId: Int) throws {

    }
}


func _postGHComment(with req: Request) throws {
    var headers = GitHub.baseHeaders
    // /repos/:owner/:repo/issues/:number/comments
    let commentURL = "https://api.github.com/repos/LoganWright/penny-test-repository/issues/1/comments"
    struct Comment: Content {
        let body: String
    }

    let comment = Comment(body: "Hello, from the api!")
    let client = try req.make(Client.self)
    let send = client.post(commentURL, headers: headers, content: comment)

    //    let send = client.send(.GET, to: comps.url!)
    send.catch { error in
        print(error)
    }

    let _ = send.map { resp -> String in
        let url = resp.content[String.self, at: "url"]

        print(resp)
        print()
        return "hi"
    }
}
