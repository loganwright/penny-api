import Vapor

private let rtmapi = URL(string: "https://slack.com/api/rtm.start")!

private func rtmQueryUrl(token: String) -> URL {
    var comps = URLComponents(url: rtmapi, resolvingAgainstBaseURL: false)!
    let tokenQuery = URLQueryItem(name: "token", value: token)
    comps.queryItems = [tokenQuery]
    return comps.url!
}

func loadRealtimeApi(with worker: Container, token: String) throws -> Future<String> {
    struct Response: Codable {
        let url: String
    }

    let url = rtmQueryUrl(token: token)

    let client = try worker.client()
    let send = client.get(url)
    return send.flatMap(to: String.self) { resp in
        let resp = try resp.content.decode(Response.self)
        return resp.map { $0.url }
    }
}

func connect(to url: String) {
    
}
