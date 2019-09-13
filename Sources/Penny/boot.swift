import Routing
import Vapor

public func build() throws -> Application {
    var config = Config.default()
    var env = try Environment.detect()
    var services = Services.default()

    try configure(&config, &env, &services)

    let app = try Application(
        config: config,
        environment: env,
        services: services
    )

    return app
}

public func start() -> Never {
    do {
        let app = try build()
        try app.run()
        exit(0)
    } catch {
        print(error)
        exit(1)
    }
}
