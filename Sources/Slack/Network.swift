//import Vapor
//
//struct Network {
//    let token: String
//    let worker: Container
//
//    let headers: HTTPHeaders
//
//    init(_ worker: Container, token: String) {
//        self.worker = worker
//        self.token = token
//        self.headers = HTTPHeaders([("Authorization", "Bearer \(token)")])
//    }
//
//    func postComment(channel: String, text: String, thread_ts: String?) throws -> Future<Response> {
//        let comment = Comment(
//            token: token,
//            channel: channel,
//            text: text,
//            thread_ts: thread_ts
//        )
//        let url = "https://slack.com/api/chat.postMessage"
//        let client = try worker.client()
//        return client.post(url, headers: headers, content: comment)
//    }
//
//    func postEmoji(emoji: String, channel: String, ts: String) throws -> Future<Response> {
//        struct Emoji: Content {
//            let token: String
//            let name: String
//            let channel: String
//            let timestamp: String
//        }
//
//        let emoji = Emoji(token: token, name: emoji, channel: channel, timestamp: ts)
//
//        let url = "https://slack.com/api/reactions.add"
//        let client = try worker.client()
//        return client.post(url, headers: headers, content: emoji)
//    }
//
//    func getUser(id: String) throws -> Future<User> {
//        struct UserResponse: Content {
//            let ok: Bool
//            let user: User
//        }
//
//        let url = "https://slack.com/api/users.info?token=\(token)&user=\(id)"
//        let client = try worker.client()
//        return client
//            .post(url, headers: headers)
//            .become(UserResponse.self)
//            .map { resp in resp.user }
//
//    }
//}
//
//extension Container {
//    func client() throws -> Client {
//        return try make(Client.self)
//    }
//}
//
//extension Future where T == Response {
//    public func become<C: Content>(_ type: C.Type = C.self) -> Future<C> {
//        return flatMap(to: C.self) { result in return try result.content.decode(C.self) }
//    }
//}
