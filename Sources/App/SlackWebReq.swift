import Vapor
import Foundation
import HTTP

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

