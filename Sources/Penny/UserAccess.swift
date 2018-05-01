import Vapor
import FluentPostgreSQL

extension Bot {
    public struct UserAccess {
        let worker: Container & DatabaseConnectable

        public func findOrCreate(_ externalUser: ExternalUser) throws -> Future<User> {
            let found = try find(externalUser)
            return found.flatMap(to: User.self) { (user) -> Future<User> in
                if let user = user { return Future.map(on: self.worker) { user } }
                return self.create(externalUser)
            }
        }

        public func find(_ externalUser: ExternalUser) throws -> Future<User?> {
            let filter = try QueryFilter<PostgreSQLDatabase>(
                field: .init(name: externalUser.externalSource),
                type: .equals,
                value: .data(externalUser.externalId)
            )
            let item = QueryFilterItem.single(filter)

            let query = User.query(on: worker)
            query.addFilter(item)
            return query.first()
        }

        public func create(_ externalUser: ExternalUser) -> Future<User> {
            let user = User([externalUser.externalSource: externalUser.externalId])
            return user.save(on: worker)
        }

        public func add(_ external: ExternalUser, to existing: User) throws -> Future<User> {
            // TODO: Optimize
            return try findOrCreate(external)
                .flatMap(to: User.self) { new in
                    return try self.combine([new, existing])
            }
        }

        public func delete(_ user: User?) -> Future<Void> {
            guard let user = user else { return Future.map(on: worker) { } }
            return user.delete(on: worker)
        }

        public func combine(_ users: [User]) throws -> Future<User> {
            var allSources: [String: String] = [:]
            try users.flatMap { $0.sources } .forEach { pair in
                guard allSources[pair.key] == nil else {
                    var message = "duplicate sources found."
                    message += " you're the first to find this edge case,"
                    message += " congrats 🎉"
                    message += " we don't want you to lose coins"
                    message += " ... yell at Logan that now he has to deal with this."
                    throw message
                }

                allSources[pair.key] = pair.value
            }

            // TODO: Optimize this delete operation
            return users.map { $0.delete(on: self.worker) }
                .flatten(on: self.worker)
                .flatMap(to: User.self) { return User(allSources).save(on: self.worker) }
        }
    }
}
