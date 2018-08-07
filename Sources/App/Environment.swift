import Vapor

let AUTHORIZED_ACCESS_TOKENS =
    Environment.get("AUTHORIZED_ACCESS_TOKENS")!.components(separatedBy: ",")
