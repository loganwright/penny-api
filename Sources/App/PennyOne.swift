//
//  PennyOne.swift
//  App
//
//  Created by Logan Wright on 4/30/18.
//

import Vapor
import WebSocket
import Mint
import GitHub

// MARK: Coin Suffix

let validSuffixes = [
    "++",
    ":coin:",
    "+= 1",
    "+ 1",
    "advance(by: 1)",
    "successor()",
    "👍",
    ":+1:",
    ":thumbsup:",
    "🙌",
    ":raised_hands:",
    "🚀",
    ":rocket:"
]
extension String {
    var hasCoinSuffix: Bool {
        for suffix in validSuffixes where hasSuffix(suffix) {
            return true
        }
        return false
    }
}

// MARK: WhiteSpace

extension String {
    func trimmedWhitespace() -> String {
        var characters = self.characters

        while characters.first?.isWhitespace == true {
            characters.removeFirst()
        }
        while characters.last?.isWhitespace == true {
            characters.removeLast()
        }

        return String(characters)
    }
}

extension Character {
    fileprivate var isWhitespace: Bool {
        switch self {
        case " ", "\t", "\n", "\r":
            return true
        default:
            return false
        }
    }
}

import Foundation

let PENNY = "U1PF52H9C"
let GENERAL = "C0N67MJ83"

import PennyCore

func handle(msg: IncomingMessage, worker: DatabaseConnectable & Container) {
    let last3Seconds = NSDate().timeIntervalSince1970 - 3
    guard
        let ts = Double(msg.ts),
        ts >= last3Seconds
        else { return }

    let processor = MessageProcessor()


    let trimmed = msg.text.trimmedWhitespace()
    let fromId = msg.user
    if processor.shouldGiftCoin(in: trimmed) {
        // D == DM
        // G == Group or Private
        // C == Public Channel
        guard msg.channel.starts(with: "C") else {
            print("Sneaky bastard, trying to get private coins")
            // TODO: Send sneaky bastard snarky message
            return
        }

        // Avoid Loop
        guard fromId != PENNY else { return }
        let idsToGift = processor.userIdsToGift(in: trimmed, fromId: fromId)
        guard
            let toId = trimmed.components(separatedBy: "<@").last?.components(separatedBy: ">").first,
            toId != fromId,
            fromId != PENNY
            else { return }

        struct SlackUser: ExternalUser {
            var externalId: String
            var externalSource: String
        }

        let user = SlackUser(externalId: toId, externalSource: "slack")
        let bot = Mint.Bot(worker)
        let count = bot.coins.give(to: toId, from: fromId, source: "slack", reason: "'twas but a gift.")
            .then { try bot.allCoins(for: user) }
            .map { $0.compactMap { $0.value } .reduce(0, +) }

        let _ = count.flatMap(to: HTTPStatus.self) { total in
            let slack = Slack(token: SLACK_BOT_TOKEN, worker: worker)
            let comment = "<@\(toId)> has \(total) :coin:"
            do {
                try slack.postComment(
                    channel: msg.channel,
                    text: comment,
                    thread_ts: msg.thread_ts ?? msg.ts
                    )
                    .run()
            } catch { print("\(#file):\(#line) - \(error)") }

            do {
                try slack.postEmoji(emoji: "penny-dev", channel: msg.channel, ts: msg.ts)
                    .run()
            } catch { print("\(#file):\(#line) - \(error)") }

            // TODO: Remove
            return Future.map(on: worker) { .ok }
        }
    } else if trimmed.lowercased().contains("connect github") {
        guard let login = trimmed.split(separator: " ").last.flatMap(String.init) else {
            print("unable to parse github login")
            return
        }

        let github = GitHub.API(worker)
        let slack = Slack(token: SLACK_BOT_TOKEN, worker: worker)
        let user = try! github.user(login: login)

        let newIssue = try! slack.getUser(id: msg.user).flatMap(to: GitHub.Issue.self) { user in
            let slackLogin = user.name
            var verification = "Hey there, @\(login), "
            verification += "\(slackLogin) from slack, wants to link this GitHub account."
            verification += "\n\n"
            verification += "Continue:\n"
            verification += "Comment on this issue with the word, `verify`."
            verification += "\n\n"
            verification += "**THAT'S NOT ME!**\n"
            verification += "Comment on this issue with the word, `fraud`."
            verification += "\n\n"
            verification += "Something Else:\n"
            verification += "Type anything else to close this issue."

            return try github.postIssue(user: "penny-coin", repo: "validation", title: "Verifying: \(login)", body: verification)
        }

        newIssue.and(user).map(to: Void.self) { issue, user in
            print(user)
            let linkRequest = AccountLinkRequest(
                    initiationId: fromId,
                    initiationSource: "slack",
                    requestedId: user.externalId,
                    requestedSource: user.externalSource,
                    reference: issue.id.description
                )
                .save(on: worker)

            linkRequest.flatMap(to: Response.self) { link in
                    print("Link: \(link)")
                    print("Issue: \(issue)")
                    let url = issue.html_url
                    let text = "Visit \(url) to connect your GitHub account."
                    return try slack.postComment(channel: msg.channel, text: text, thread_ts: msg.thread_ts ?? msg.ts)
                }.run()

            return
        }.run()
//
//        linkRequest.flatMap(to: Response.self) { (link, issue) in
//            print("Link: \(link)")
//            print("Issue: \(issue)")
//            let url = issue.html_url
//            let text = "Visit \(url) to connect your GitHub account."
//            return try slack.postComment(channel: msg.channel, text: text, thread_ts: msg.thread_ts ?? msg.ts)
//        }.run()
    }
//    else if trimmed.hasPrefix("<@U1PF52H9C>") || trimmed.hasSuffix("<@U1PF52H9C>") {
//        if trimmed.lowercased().contains(any: "hello", "hey", "hiya", "hi", "aloha", "sup") {
//            let response = SlackMessage(to: channel,
//                                        text: "Hey <@\(fromId)> 👋",
//                threadTs: threadTs)
//            try ws.send(response)
//        } else if trimmed.lowercased().contains("version") {
//            let response = SlackMessage(to: channel,
//                                        text: "Current version is \(VERSION)",
//                threadTs: threadTs)
//            try ws.send(response)
//        } else if trimmed.lowercased().contains("environment") {
//            let env = config["app", "env"]?.string ?? "debug"
//            let response = SlackMessage(to: channel,
//                                        text: "Current environment is \(env)",
//                threadTs: threadTs)
//            try ws.send(response)
//        } else if trimmed.lowercased().contains("top") {
//            let limit = trimmed.components(separatedBy: " ")
//                .last
//                .flatMap { Int($0) }
//                ?? 10
//            let top = try mysql.top(limit: limit).map { "- <@\($0["user"]?.string ?? "?")>: \($0["coins"]?.int ?? 0)" } .joined(separator: "\n")
//            let response = SlackMessage(to: channel,
//                                        text: "Top \(limit): \n\(top)",
//                threadTs: threadTs)
//            try ws.send(response)
//        } else if trimmed.lowercased().contains("how many coins") {
//            let user = trimmed.components(separatedBy: " ")
//                .lazy
//                .filter({
//                    $0.hasPrefix("<@")
//                        && $0.hasSuffix(">")
//                        && $0 != "<@U1PF52H9C>"
//                })
//                .map({ $0.characters.dropFirst(2).dropLast() })
//                .first
//                .flatMap({ String($0) })
//                ?? fromId
//
//            let count = try mysql.coinsCount(for: user)
//            let response = SlackMessage(to: channel,
//                                        text: "<@\(user)> has \(count) :coin:",
//                threadTs: threadTs)
//            try ws.send(response)
//        }
}

//func foo(ws: WebSocket, text: String) throws {
//    let event = try JSON(bytes: text.utf8.array)
//    let last3Seconds = NSDate().timeIntervalSince1970 - 3
//    guard
//        let channel = event["channel"]?.string,
//        let message = event["text"]?.string,
//        let fromId = event["user"]?.string,
//        let ts = event["ts"].flatMap({ $0.string.flatMap({ Double($0) }) }),
//        ts >= last3Seconds
//        else { return }
//
//    let threadTs = event["thread_ts"]?.string
//    let trimmed = message.trimmedWhitespace()
//    if trimmed.hasPrefix("<@") && trimmed.hasCoinSuffix { // leads w/ user
//        guard
//            let toId = trimmed.components(separatedBy: "<@").last?.components(separatedBy: ">").first,
//            toId != fromId,
//            fromId != "" // PENNY
//            else { return }
//
//        if true { // validChannels.contains(channel) {
//            let total = try mysql.addCoins(for: toId)
//            let response = SlackMessage(to: channel,
//                                        text: "<@\(toId)> has \(total) :coin:",
//                threadTs: threadTs)
//            try ws.send(response)
//        } else {
//            let response = SlackMessage(to: channel,
//                                        text: "Sorry, I only work in public channels. Try thanking <@\(toId)> in <#\(GENERAL)>",
//                threadTs: threadTs)
//            try ws.send(response)
//        }
//    } else if trimmed.hasPrefix("<@U1PF52H9C>") || trimmed.hasSuffix("<@U1PF52H9C>") {
//        if trimmed.lowercased().contains(any: "hello", "hey", "hiya", "hi", "aloha", "sup") {
//            let response = SlackMessage(to: channel,
//                                        text: "Hey <@\(fromId)> 👋",
//                threadTs: threadTs)
//            try ws.send(response)
//        } else if trimmed.lowercased().contains("version") {
//            let response = SlackMessage(to: channel,
//                                        text: "Current version is \(VERSION)",
//                threadTs: threadTs)
//            try ws.send(response)
//        } else if trimmed.lowercased().contains("environment") {
//            let env = config["app", "env"]?.string ?? "debug"
//            let response = SlackMessage(to: channel,
//                                        text: "Current environment is \(env)",
//                threadTs: threadTs)
//            try ws.send(response)
//        } else if trimmed.lowercased().contains("top") {
//            let limit = trimmed.components(separatedBy: " ")
//                .last
//                .flatMap { Int($0) }
//                ?? 10
//            let top = try mysql.top(limit: limit).map { "- <@\($0["user"]?.string ?? "?")>: \($0["coins"]?.int ?? 0)" } .joined(separator: "\n")
//            let response = SlackMessage(to: channel,
//                                        text: "Top \(limit): \n\(top)",
//                threadTs: threadTs)
//            try ws.send(response)
//        } else if trimmed.lowercased().contains("how many coins") {
//            let user = trimmed.components(separatedBy: " ")
//                .lazy
//                .filter({
//                    $0.hasPrefix("<@")
//                        && $0.hasSuffix(">")
//                        && $0 != "<@U1PF52H9C>"
//                })
//                .map({ $0.characters.dropFirst(2).dropLast() })
//                .first
//                .flatMap({ String($0) })
//                ?? fromId
//
//            let count = try mysql.coinsCount(for: user)
//            let response = SlackMessage(to: channel,
//                                        text: "<@\(user)> has \(count) :coin:",
//                threadTs: threadTs)
//            try ws.send(response)
//        }
//    }
//}
