import Vapor

let AUTHORIZED_TOKENS =
    Environment.get("AUTHORIZED__ACCESS_TOKENS")!.components(separatedBy: ",")
let PENNY_GITHUB_TOKEN =
    Environment.get("PENNY_GITHUB_TOKEN")!
let GITHUB_WEBHOOK_SECRET =
    Environment.get("GITHUB_WEBHOOK_SECRET")!
