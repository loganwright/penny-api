import Vapor

struct Comment: Content {
    let token: String
    let channel: String
    let text: String
    let thread_ts: String?
}
