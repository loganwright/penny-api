import Vapor
import Mint
import Penny

extension Network {
    public struct LinkRequestsAccess {
        let baseUrl: String

        let worker: Container
        let headers: HTTPHeaders

        public func all() throws -> Future<[AccountLinkRequest]> {
            let client = try worker.client()
            return client.get(baseUrl, headers: headers).become()
        }

        public func find(requestedSource: String, requestedId: String, reference: String) throws -> Future<AccountLinkRequest> {
            let url = baseUrl + "/\(requestedSource)/\(requestedId)/\(reference)"
            let client = try worker.client()
            return client.get(url, headers: headers).become()

        }

        public func add(_ link: AccountLinkRequest) throws -> Future<AccountLinkRequest> {
            let client = try worker.client()
            return client.post(baseUrl, headers: headers, content: link).become()
        }

        public func approve(_ link: AccountLinkRequest) throws -> Future<Account> {
            let url = baseUrl + "/approve"
            let client = try worker.client()
            return client.post(url, headers: headers, content: link).become()
        }

        public func requestConnectGitHub(
            login: String,
            source: String,
            sourceName: String,
            sourceId: String
        ) throws -> Future<GitHubLinkResponse> {
            let link = GitHubLinkRequest(
                login: login,
                source: source,
                sourceName: sourceName,
                sourceId: sourceId
            )
            let url = baseUrl + "/connect-github"
            let client = try worker.client()
            return client.post(url, headers: headers, content: link).become()
        }
    }
}
