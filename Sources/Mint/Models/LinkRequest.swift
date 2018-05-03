import FluentPostgreSQL
import Foundation

//final class AccountLinkRequest: Codable {
//    var id: UUID?
//
//    var created: Date
//
//    var initiationId: String
//    var initiationSource: String
//
//    var requestedId: String
//    var requestedSource: String
//
//    var reference: String
//
//    init(initiationId: String, initiationSource: String, requestedId: String, requestedSource: String, reference: String) {
//        self.initiationId = initiationId
//        self.initiationSource = initiationSource
//        self.requestedSource = requestedSource
//        self.requestedId = requestedId
//        self.created = Date()
//        self.reference = reference
//    }
//}
//
//extension AccountLinkRequest {
//    static func fetch(on worker: DatabaseConnectable & Container, requestedSource: String, requestedId: String, reference: String) throws -> Future<AccountLinkRequest?> {
//        let query = AccountLinkRequest.query(on: worker)
//        let source = try QueryFilter<PostgreSQLDatabase>(
//            field: "requestedSource",
//            type: .equals,
//            value: .data(requestedSource)
//        )
//        let id = try QueryFilter<PostgreSQLDatabase>(
//            field: "requestedId",
//            type: .equals,
//            value: .data(requestedId)
//        )
//        let ref = try QueryFilter<PostgreSQLDatabase>(
//            field: "reference",
//            type: .equals,
//            value: .data(reference)
//        )
//
//        let items = [source, id, ref].map(QueryFilterItem.single)
//        let group = QueryFilterItem.group(.and, items)
//        query.addFilter(group)
//        return query.first()
//    }
//}
//
//extension AccountLinkRequest: PostgreSQLUUIDModel {}
//extension AccountLinkRequest: Content {}
//extension AccountLinkRequest: Migration {}
//extension AccountLinkRequest: Parameter {}
//
