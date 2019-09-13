import Vapor
import PennyConnector

extension Container {
    var penny: PennyConnector.Network {
        return PennyConnector.Network(self, baseUrl: PENNY_API_BASE_URL, token: PENNY_API_TOKEN)
    }

    var github: Network {
        return Network(self, token: GITHUB_API_TOKEN)
    }
}

extension Container {
    func client() throws -> Client {
        return try make(Client.self)
    }
}

extension Future where T == Response {
    func become<C: Content>(_ type: C.Type = C.self) -> Future<C> {
        return flatMap(to: C.self) { result in return try result.content.decode(C.self) }
    }
}

extension Client {
    func post<C>(_ url: URLRepresentable, headers: HTTPHeaders = .init(), content: C) -> Future<Response> where C: Content {
        return send(.POST, headers: headers, to: url) { try $0.content.encode(content) }
    }

    func patch<C>(_ url: URLRepresentable, headers: HTTPHeaders = .init(), content: C) -> Future<Response> where C: Content {
        return send(.PATCH, headers: headers, to: url) { try $0.content.encode(content) }
    }
}

