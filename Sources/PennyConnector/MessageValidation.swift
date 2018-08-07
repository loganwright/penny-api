import Vapor
import Mint
import Penny

extension Network {
    public struct MessageValidator {
        let url: String
        let worker: Container
        let headers: HTTPHeaders

        public func validate(_ body: String) throws -> Future<Bool> {
            let client = try worker.client()
            return client.post(url, headers: headers)
                .become(GiftMessageResponse.self)
                .map { $0.shouldGift }
        }
    }
}
