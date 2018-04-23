import Vapor
import Crypto

extension String: Error {}

public func validateWebHook(_ req: Request, secret: String) throws {
    guard
        let signature = req.http.headers["X-Hub-Signature"].first,
        let data = req.http.body.data
        else { throw "invalid request" }

    let digest = try HMAC.SHA1
        .authenticate(data, key: secret)
        .hexEncodedString()

    let complete = "sha1=\(digest)"
    guard complete == signature else { throw "invalid request: unauthorized" }
}
