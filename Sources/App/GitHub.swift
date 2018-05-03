//import Vapor
//import Foundation
//import HTTP
//import WebSocket
//import GitHub
//
//let ghtoken = "a3047d12ec84a96f58605df720fbda3d41f698dd"
//
//struct AAGitHub {
//    static let baseUrl = "https://api.github.com"
//    static let baseHeaders = HTTPHeaders(
//        [
//            ("Authorization", "Bearer \(ghtoken)"),
//            ("Accept", "application/vnd.github.v3+json"),
//        ]
//    )
//
//    let worker: Container
//
//    init(_ worker: Container) {
//        self.worker = worker
//    }
//
//    func postComment(_ body: String, issue: Int, username: String, project: String) throws -> Future<Response> {
//        let headers = AAGitHub.baseHeaders
//        let commentURL = "\(AAGitHub.baseUrl)/repos/\(username)/\(project)/issues/\(issue)/comments"
//
//        struct Comment: Content {
//            let body: String
//        }
//
//        let comment = Comment(body: body)
//        let client = try worker.make(Client.self)
//        let send = client.post(commentURL, headers: headers, content: comment)
//        return send.map { resp -> Response in
////            let url = resp.content[String.self, at: "url"]
//            print(resp)
//            print()
//            return resp
//        }
//    }
//
//    func postIssueComment(_ body: String, fullRepoName: String, issue: Int) throws -> Future<Response> {
//        let headers = AAGitHub.baseHeaders
//        let commentURL = "\(AAGitHub.baseUrl)/repos/\(fullRepoName)/issues/\(issue)/comments"
//
//        struct Comment: Content {
//            let body: String
//        }
//
//        let comment = Comment(body: body)
//        let client = try worker.make(Client.self)
//        let send = client.post(commentURL, headers: headers, content: comment)
//        return send.map { resp -> Response in
//            //            let url = resp.content[String.self, at: "url"]
//            print(resp)
//            print()
//            return resp
//        }
//    }
//
//    func postComment(to pullRequest: PullRequest, _ body: String) throws -> Future<Response> {
//        let commentsUrl = pullRequest.comments_url
//        let headers = AAGitHub.baseHeaders
//
//        struct Comment: Content {
//            let body: String
//        }
//
//        let comment = Comment(body: body)
//        let client = try worker.make(Client.self)
//        let send = client.post(commentsUrl, headers: headers, content: comment)
//        return send.map { resp -> Response in
//            return resp
//        }
//    }
//
//    func updateComment(_ body: String, commentId: Int) throws {
//
//    }
//}
//
//func _postGHComment(with req: Request) throws {
//    let headers = AAGitHub.baseHeaders
//    // /repos/:owner/:repo/issues/:number/comments
//    let commentURL = "https://api.github.com/repos/LoganWright/penny-test-repository/issues/1/comments"
//    struct Comment: Content {
//        let body: String
//    }
//
//    let comment = Comment(body: "Hello, from the api!")
//    let client = try req.make(Client.self)
//    let send = client.post(commentURL, headers: headers, content: comment)
//
//    //    let send = client.send(.GET, to: comps.url!)
//    send.catch { error in
//        print(error)
//    }
//
//    let _ = send.map { resp -> String in
//        let url = resp.content[String.self, at: "url"]
//
//        print(resp)
//        print()
//        return "hi"
//    }
//}
