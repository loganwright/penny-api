import Vapor
import Foundation
import HTTP

func loadRealtimeApi(with app: Application) throws {
    let token = Environment.get("BOT_TOKEN")!
    let tokenQuery = URLQueryItem(name: "token", value: token)
    guard var url = URL(string: "https://slack.com/api/rtm.start") else { fatalError("Slack realtime URL failed") }
    var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    comps.queryItems = [tokenQuery]

    let client = try app.make(Client.self)
    let send = client.send(.GET, to: comps.url!)
    send.catch { error in
        print(error)
    }

    let foo = send.map { resp -> String in
        print(resp)
        print()
        return "hi"
    }

//    let req = HTTPRequest(method: .GET, url: URL(string: "https://slack.com/api/rtm.start")!, headers: HTTPHeaders.init([:]), body: <#T##HTTPBody#>)
//    var request = Request.init(http: <#T##HTTPRequest#>, using: <#T##Container#>)
//    client.send(.get, to: "wordApi", content: SlackQuery(token: token))
//    return send.flatMap(to: [WordResult].self) { response in
//        return try [WordResult].decode(from: response, for: request)
//        }
//        .map(to: String.self) { words in
//            words.map { $0.word } .joined(separator: ".") .lowercased()
//    }

//    fatalError()
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

