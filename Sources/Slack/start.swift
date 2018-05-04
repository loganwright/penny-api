import Vapor

public func start(worker: Container & DatabaseConnectable, botToken: String) throws {
    let api = try loadRealtimeApi(with: worker, token: botToken)
    api.addAwaiter { result in
        guard let url = result.result else { fatalError("unable to boot slackbot") }
        let listener = Listener(worker, url: url)
        try! listener.start()
    }
}
