import Vapor

let PENNY = "U1PF52H9C"

struct MessageHandler {
    let processor = MessageProcessor()

    let worker: Container & DatabaseConnectable
    let msg: IncomingMessage
    let slack: Network

    init(_ worker: Container & DatabaseConnectable, msg: IncomingMessage, token: String) {
        self.worker = worker
        self.msg = msg
        self.slack = Network(worker, token: token)
    }

    func handle() throws {
        try self.slack.postComment(
            channel: self.msg.channel,
            text: "echo, ya'll",
            thread_ts: self.msg.thread_ts ?? self.msg.ts
        )

        return 
        let from = msg.user

        // coin parsing
        if processor.shouldGiftCoin(in: msg.text) {
            let usersToGift = processor.userIdsToGift(in: msg.text, fromId: msg.user)
            let response = try giveCoins(to: usersToGift, from: from, on: worker)
            _ = response.flatMap(to: Response.self) { response in
                try self.slack.postComment(
                    channel: self.msg.channel,
                    text: response,
                    thread_ts: self.msg.thread_ts ?? self.msg.ts
                )
            }
        } else if msg.text.contains("<@\(PENNY)>") {
            if msg.text.lowercased().contains("how many") {
                fatalError()
//                totalCoins(for: from, respond: msg)
            } else if msg.text.lowercased().contains("connect github") {
//                try connectGitHub(msg: msg)
                fatalError()
            } else if msg.text.contains("env") {
                let env = ProcessInfo.processInfo.environment["ENVIRONMENT"]
                    ?? "the void"
//                msg.reply(with: "I'm in \(env)")
                fatalError()
            }
        } else if msg.text == "!ping" {
//            msg.reply(with: "pong!")
        }
    }
}
