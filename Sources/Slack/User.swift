import Vapor

struct User: Content {
    let id: String
    let team_id: String
    let name: String
    let is_bot: Bool
}
