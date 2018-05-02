import Vapor
import Foundation
import HTTP
import WebSocket

//let ghtoken = "a3047d12ec84a96f58605df720fbda3d41f698dd"


struct Slack {
    let token: String
    let worker: Container

    func postComment(channel: String, text: String, thread_ts: String?) throws -> Future<Response> {
        struct SlackComment: Content {
            let token: String
            let channel: String
            let text: String
            let thread_ts: String?
        }

        let comment = SlackComment(token: token, channel: channel, text: text, thread_ts: thread_ts)
        let url = "https://slack.com/api/chat.postMessage"
        let client = try worker.make(Client.self)
        return client.post(url, headers: HTTPHeaders.init([("Authorization", "Bearer \(token)")]), content: comment)
//        return client.post(url, content: comment).map { resp in
//            print("\n\nMESSAAGE RESPONSE\n\n\(resp)\n\n")
//            return Future.map(on: self.worker) { resp }
//        }
    }

    func postEmoji(emoji: String, channel: String, ts: String) throws -> Future<Response> {
        struct Emoji: Content {
            let token: String
            let name: String
            let channel: String
            let timestamp: String
        }

        let emoji = Emoji(token: token, name: emoji, channel: channel, timestamp: ts)
        let url = "https://slack.com/api/reactions.add"
        let client = try worker.make(Client.self)
        return client.post(url, headers: HTTPHeaders.init([("Authorization", "Bearer \(token)")]), content: emoji)

    }

    func getUser(id: String) throws -> Future<SlackUser> {
        struct UserResponse: Content {
            let ok: Bool
            let user: SlackUser
        }

        let url = "https://slack.com/api/users.info?token=\(token)&user=\(id)"
        let client = try worker.make(Client.self)
        return client
            .post(url, headers: HTTPHeaders.init([("Authorization", "Bearer \(token)")]))
            .become(UserResponse.self)
            .map { resp in resp.user }

    }
}

struct SlackUser: Content {
    let id: String
    let team_id: String
    let name: String
    let is_bot: Bool
}

func postGHComment(with req: Request) throws {
    let headers = HTTPHeaders(
        [
            ("Authorization", "Bearer \(ghtoken)"),
            ("Accept", "application/vnd.github.v3+json"),
        ]
    )

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

let SLACK_BOT_TOKEN = "xoxb-53115077872-1xDViI7osWlVEyDqwVJqj2x7"//Environment.get("BOT_TOKEN")!

func loadRealtimeApi(with app: Application) throws {
    let tokenQuery = URLQueryItem(name: "token", value: SLACK_BOT_TOKEN)
    guard let url = URL(string: "https://slack.com/api/rtm.start") else { fatalError("Slack realtime URL failed") }
    var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    comps.queryItems = [tokenQuery]

    let client = try app.make(Client.self)
    let send = client.send(.GET, to: comps.url!)
    send.catch { error in
        print(error)
    }

    let foo = send.flatMap(to: String.self) { resp -> Future<String> in
        // MARK:
//        print("Realtime api resp: \n\n********\n\n\(resp)\n\n********\n\n")
        print("")
        let req = Request(using: app)
        return try resp.content[String.self, at: "url"].flatMap(to: String.self) { (string) -> Future<String> in
            try connect(to: string!, worker: req)
            return Future.map(on: app) { string ?? "" }
        }
    }
}

import WebSocket

var ws: WebSocket!

func _connect(to urlString: String, worker: Container) throws {
    let urlString = "wss://echo.websocket.org"
    guard let url = URL(string: urlString), let host = url.host else {
        return
    }

    let path = url.path.isEmpty ? "/" : url.path

    let _ = HTTPClient.webSocket(
        scheme: .wss,
        hostname: host,
        port: url.port,
        path: path,
        on: worker
        ).map { _ws -> String in
            ws = _ws
            //            {"id":1524536803,"channel":"D1KA314QK","type":"message","text":"Echo: asdf"}
            let asdf = SlackMessage(to: "D1KA314QK", text: "Hey there")
            ws.send(asdf)

            ws.onBinary { (ws, data) in
                print("Binary rec'd")
            }
            ws.onText { ws, text in
                print("Got: \(text)")
                let newMessage = SlackMessage(to: "asfd", text: "Echo: \(text)")
                ws.send(newMessage)
            }

            ws.onClose.always {
                print("We done here")
            }

            return ""
    }
}

func connect(to urlString: String, worker: Container & DatabaseConnectable) throws {
    guard let url = URL(string: urlString), let host = url.host else {
        return
    }

    let path = url.path.isEmpty ? "/" : url.path

    let _ = HTTPClient.webSocket(
        scheme: .wss,
        hostname: host,
        port: url.port,
        path: path,
        on: worker
        ).map { ws -> String in
            ws.onText { ws, text in
                let data = text.data(using: .utf8)!
                let packet = try! IncomingPacket.make(with: data)
                guard packet.type == "message", packet.subtype != "bot_message" else {
                    if packet.type == "hello" { print("Penny slack, ONLINE.") }
                    else { print("Got message: \(text)") }
                    return
                }
//                print("MESG: \(text)")
                guard let message = try? text.parse() else {
                    print("Couldn't parse message: \(text)")
                    return
                }

                handle(msg: message, worker: worker)
                //                let message = try! text.parse()
//                print("got messag: \(message)")
//                let newMessage = SlackMessage(to: message.channel, text: "Echo: \(message.text)")
//                let slack = Slack(token: SLACK_BOT_TOKEN, worker: worker)
//                do {
//                    try slack.postComment(
//                        channel: newMessage.channel,
//                        text: "Bza-- \(newMessage.text)",
//                        thread_ts: message.thread_ts ?? message.ts
//                    )
//                    .run()
//                } catch { print("\(#file):\(#line) - \(error)") }
//
//                do {
//                    try slack.postEmoji(emoji: "penny-dev", channel: message.channel, ts: message.ts)
//                        .run()
//                } catch { print("\(#file):\(#line) - \(error)") }
            }

            ws.onClose.always {
                print("We done here")
            }
            return "hey"
    }
}

extension Future {
    func run() {
        let _ = self.map(to: Void.self) { _ in }
    }
}

extension Content {
    static func make(with data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}

struct IncomingPacket: Content {
    let type: String
    let subtype: String?
}

extension WebSocket {
    func send(_ location: SlackMessage) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(location) else { return }
        let string = String(decoding: data, as: UTF8.self)
        print("Sending: \(string)")
        send(string)
    }
}

extension String {
    func parse() throws -> IncomingMessage {
        let decoder = JSONDecoder()
        return try decoder.decode(IncomingMessage.self, from: self.data(using: .utf8) ?? Data())
    }
}

/*
 {"text":"Bza-- Echo: cool, cool cool cool","username":"bot","bot_id":"B1K3PLJ4R","type":"message","subtype":"bot_message","team":"T0N650MLL","channel":"D1KA314QK","event_ts":"1525140071.000060","ts":"1525140071.000060"}

 */
struct IncomingMessage: Content {
    var channel: String
    var user: String
    var text: String
    var ts: String
    var thread_ts: String?
}

import Random

struct SlackMessage: Content {
    let id: UInt32
    let type: String
    let channel: String
    let text: String
//    let ts: String?

    init(to channel: String, text: String) {
        // MARK: Make Random
        self.id = UInt32(Date().timeIntervalSince1970)
        self.type = "message"
        self.channel = channel
        self.text = text
    }
}

struct SlackQuery: Content {
    let token: String
}

//func setupClient() {
//    defaultClientConfig = {
//        return try TLS.Config(context: try Context(mode: .client), certificates: .none, verifyHost: false, verifyCertificates: false, cipher: .compat)
//    }
//}
//
//extension HTTP.Client {
//    static func loadRealtimeApi(token: String, simpleLatest: Bool = true, noUnreads: Bool = true) throws -> HTTP.Response {
//        let headers: [HeaderKey: String] = ["Accept": "application/json; charset=utf-8"]
//        let query: [String: CustomStringConvertible] = [
//            "token": token,
//            "simple_latest": simpleLatest.queryInt,
//            "no_unreads": noUnreads.queryInt
//        ]
//
//        return try get(
//            "https://slack.com/api/rtm.start",
//            headers: headers,
//            query: query
//        )
//    }
//}
//
//extension Bool {
//    fileprivate var queryInt: Int {
//        // slack uses 1 / 0 in their demo
//        return self ? 1 : 0
//    }
//}


private let apiKey = "a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5"
private let wordAPI = "http://api.wordnik.com/v4/words.json/randomWords?hasDictionaryDef=true&minLength=5&maxLength=10&limit=3&api_key=\(apiKey)"

private struct WordResult: Content {
    let id: Int
    let word: String
}

final class KeyGenerator {
    static func randomKey(for request: Request) throws -> Future<String> {
        let client = try request.make(Client.self)
        let send = client.send(.GET, to: wordAPI)
        send.catch { error in
            print(error)
        }
        return send.flatMap(to: [WordResult].self) { response in
            return try [WordResult].decode(from: response, for: request)
            }
            .map(to: String.self) { words in
                words.map { $0.word } .joined(separator: ".") .lowercased()
        }
    }
}

