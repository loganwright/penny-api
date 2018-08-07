//import Vapor
//
//struct Listener {
//    let worker: Container & DatabaseConnectable
//    let url: URL
//    let token: String
//
//    init(_ worker: Container & DatabaseConnectable, url: String, token: String) {
//        self.worker = worker
//        self.url = URL(string: url)!
//        self.token = token
//    }
//
//    func start() throws {
//        let host = url.host!
//        let path = url.path.isEmpty ? "/" : url.path
//        let ws = HTTPClient.webSocket(
//            scheme: .wss,
//            hostname: host,
//            port: url.port,
//            path: path,
//            on: worker
//        )
//
//        ws.addAwaiter { ws in
//            guard let ws = ws.result else { fatalError("unable to start slackbot") }
//            self.setup(ws)
//        }
//    }
//
//    private func setup(_ ws: WebSocket) {
//        ws.onText { ws, text in
//            do { try self.onText(ws: ws, text: text) }
//            catch { print("SlackBot Error: \(error)")}
//        }
//
//        ws.onClose.always {
//            print("SlackBot Disconnected, attempt to reconnect: \(Date()).")
//        }
//    }
//
//    private func onText(ws: WebSocket, text: String) throws {
//        let packet = try text.utf8.become(IncomingPacket.self)
//        if packet.type == "hello" {
//            print("Penny is online.")
//            return
//        }
//
//        // Right now, only support messages
//        guard packet.type == "message", packet.subtype != "bot_message" else {
//            return
//        }
//
//        let message = try text.utf8.become(IncomingMessage.self)
//        let handler = MessageHandler(worker, msg: message, token: token)
//        try handler.handle()
//    }
//}
//
//struct IncomingMessage: Content {
//    var channel: String
//    var user: String
//    var text: String
//    var ts: String
//    var thread_ts: String?
//}
//
//struct IncomingPacket: Content {
//    let type: String
//    let subtype: String?
//}
//
//extension Data {
//    func become<C: Codable>(_ type: C.Type = C.self) throws -> C {
//        let decoder = JSONDecoder()
//        return try decoder.decode(C.self, from: self)
//    }
//}
//
//extension String {
//    var utf8: Data {
//        return data(using: .utf8) ?? Data()
//    }
//}
