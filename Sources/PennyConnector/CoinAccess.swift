import Vapor
import Mint
import Penny

extension Network {
    public struct CoinsAccess {
        let baseUrl: String

        let worker: Container
        let headers: HTTPHeaders

        public func all() throws -> Future<[Coin]> {
            let client = try worker.client()
            return client.get(baseUrl, headers: headers).become()
        }

        public func all(source: String, id: String) throws -> Future<[Coin]> {
            let url = baseUrl + "/\(source)/\(id)"
            let client = try worker.client()
            return client.get(url, headers: headers).become()
        }

        public func total(source: String, id: String) throws -> Future<TotalCoinsResponse> {
            let url = baseUrl + "/\(source)/\(id)/total"
            let client = try worker.client()
            return client.get(url, headers: headers).become()
        }

        public func add(_ coins: [Coin]) throws -> Future<[CoinResponse]> {
            let client = try worker.client()
            return client.post(baseUrl, headers: headers, content: coins).become()
        }
    }
}
