import Foundation
import Vapor

public struct PullRequest: Content, Commentable {
    public let merged: Bool
    public let author_association: String // != OWNER
    public let user: User
    public let merged_by: User?
    public let number: Int
    public let comments_url: String
}
