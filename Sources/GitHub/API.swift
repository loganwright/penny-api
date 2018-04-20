import Vapor

// TODO: Must Hide w/ Key
let ghtoken = "a3047d12ec84a96f58605df720fbda3d41f698dd"
let baseUrl = "https://api.github.com"

extension String: Error {}

func validateWebHook(_ req: Request, secret: String) throws {
    guard
        let signature = req.http.headers["X-Hub-Signature"].first,
        let data = req.http.body.data
        else { throw "invalid request" }

    let digest = try HMAC.SHA1
        .authenticate(data, key: GITHUB_SECRET)
        .hexEncodedString()

    let complete = "sha1=\(digest)"
    guard complete == signature else { throw "invalid request: unauthorized" }
}

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

extension User {
    static func get(with worker: Container, id: String) throws -> Future<User> {
        // https://api.github.com/user/:id
        let url = "\(GitHub.baseUrl)/user/\(id)"
        return try worker.client()
            .get(url, headers: GitHub.baseHeaders)
            .become(User.self)
    }
}

struct API {
    let worker: Worker

    init(_ worker: Worker) {
        self.worker = worker
    }

    func getUser(id: Int) -> User {
        return getUser(id: id.description)
    }

    func getUser(id: String) -> User {

        fatalError()
    }
}
