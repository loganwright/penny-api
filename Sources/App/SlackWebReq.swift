import Vapor
import Foundation
import HTTP
import WebSocket

//let ghtoken = "a3047d12ec84a96f58605df720fbda3d41f698dd"

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

func loadRealtimeApi(with app: Application) throws {
    let token = Environment.get("BOT_TOKEN")!
    let tokenQuery = URLQueryItem(name: "token", value: token)
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
        print("Realtime api resp: \n\n********\n\n\(resp)\n\n********\n\n")
        print("")
        return try resp.content[String.self, at: "url"].flatMap(to: String.self) { (string) -> Future<String> in
            try connect(to: string!, worker: app)
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

func connect(to urlString: String, worker: Container) throws {
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
                guard packet.type == "message" else {
                    print("Got unknown packet: \(text)")
                    return
                }

                let message = try! text.parse()
                print("text: \(text)")
                //                let message = try! text.parse()
                print("got messag: \(message)")

                let newMessage = SlackMessage(to: message.channel, text: "Echo: \(message.text)")
//                ws.send(newMessage)
            }

            ws.onClose.always {
                print("We done here")
            }
            return "hey"
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

struct IncomingMessage: Content {
    var channel: String
    var user: String
    var text: String
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

