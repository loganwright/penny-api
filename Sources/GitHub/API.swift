import Vapor

// TODO: Must Hide w/ Key
let ghtoken = "a3047d12ec84a96f58605df720fbda3d41f698dd"
let baseUrl = "https://api.github.com"

let baseHeaders = HTTPHeaders([
    ("Authorization", "Bearer \(ghtoken)"),
    ("Accept", "application/vnd.github.v3+json"),
])

extension Container {
    func client() throws -> Client {
        return try make(Client.self)
    }
}

extension Future where T == Response {
    func become<C: Content>(_ type: C.Type) -> Future<C> {
        return flatMap(to: C.self) { result in return try result.content.decode(C.self) }
    }
}
