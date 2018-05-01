import Vapor

extension Repo {
    static func list(with worker: Container, forOrg org: String) throws -> Future<[Repo]> {
        let url = "\(GitHub.baseUrl)/orgs/\(org)/repos"
        return try worker.client().repos(at: url)
    }

    static func list(with worker: Container, forUserName user: String) throws -> Future<[Repo]> {
        let url = "\(GitHub.baseUrl)/users/\(user)/repos"
        return try worker.client().repos(at: url)
    }
}

extension User {
    public static func fetch(with worker: Container, forUsername username: String) throws -> Future<User> {
        let url = "\(GitHub.baseUrl)/users/\(username)"
        return try worker.client().user(at: url)
    }
}

extension Client {
    func repos(at url: String) throws -> Future<[Repo]> {
        return self
            .get(url, headers: GitHub.baseHeaders)
            .become()
    }

    func user(at url: String) throws -> Future<User> {
        return self
            .get(url, headers: GitHub.baseHeaders)
            .become()
    }
}
