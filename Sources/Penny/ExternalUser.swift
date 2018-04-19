public protocol ExternalUser {
    var externalId: String { get }
    var source: String { get }
}

//public struct BasicExternalUser: ExternalUser {
//    public let externalId: String
//    public let source: String
//
//    public init(externalId: String, source: String) {
//        self.externalId = externalId
//        self.source = source
//    }
//}
