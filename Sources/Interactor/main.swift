import Vapor

let container = try Application(config: Config.default(), environment: Environment.detect(), services: Services())
let network = Network(container, baseUrl: "localhost:8080", token: "tester")

