import Vapor

struct Listener {
    let worker: Container & DatabaseConnectable
    let url: URL

    init(_ worker: Container & DatabaseConnectable, url: String) {
        self.worker = worker
        self.url = URL(string: url)!
    }

    func start() throws {
        let host = url.host!
        let path = url.path.isEmpty ? "/" : url.path

        let _ = HTTPClient.webSocket(
            scheme: .wss,
            hostname: host,
            port: url.port,
            path: path,
            on: worker
            ).map { ws -> String in

                ws.onText { ws, text in
                    print("Got text: \(text)")
                }

                return ""
        }
    }
    
}

//func connect(to urlString: String, worker: Container & DatabaseConnectable) throws {
//    guard let url = URL(string: urlString), let host = url.host else {
//        return
//    }
//
//    let path = url.path.isEmpty ? "/" : url.path
//
//    let _ = HTTPClient.webSocket(
//        scheme: .wss,
//        hostname: host,
//        port: url.port,
//        path: path,
//        on: worker
//        ).map { ws -> String in
//            ws.onText { ws, text in
//                let data = text.data(using: .utf8)!
//                let packet = try! IncomingPacket.make(with: data)
//                guard packet.type == "message", packet.subtype != "bot_message" else {
//                    if packet.type == "hello" { print("Penny slack, ONLINE.") }
//                    else { print("Got message: \(text)") }
//                    return
//                }
////                print("MESG: \(text)")
//                guard let message = try? text.parse() else {
//                    print("Couldn't parse message: \(text)")
//                    return
//                }
//
//                handle(msg: message, worker: worker)
//                //                let message = try! text.parse()
////                print("got messag: \(message)")
////                let newMessage = SlackMessage(to: message.channel, text: "Echo: \(message.text)")
////                let slack = Slack(token: SLACK_BOT_TOKEN, worker: worker)
////                do {
////                    try slack.postComment(
////                        channel: newMessage.channel,
////                        text: "Bza-- \(newMessage.text)",
////                        thread_ts: message.thread_ts ?? message.ts
////                    )
////                    .run()
////                } catch { print("\(#file):\(#line) - \(error)") }
////
////                do {
////                    try slack.postEmoji(emoji: "penny-dev", channel: message.channel, ts: message.ts)
////                        .run()
////                } catch { print("\(#file):\(#line) - \(error)") }
//            }
//
//            ws.onClose.always {
//                print("We done here")
//            }
//            return "hey"
//    }
//}
