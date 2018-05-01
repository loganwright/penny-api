import Foundation
import Vapor

public protocol Commentable {
    var comments_url: String { get }
}

public struct PullRequest: Content, Commentable {
    public let merged: Bool
    public let author_association: String // != OWNER
    public let user: User
    public let merged_by: User?
    public let number: Int
    public let comments_url: String
}

public struct Issue: Content, Commentable {
    public let id: Int
    
    public let title: String
    public let body: String?

    public let state: String
    public let number: Int
    public let comments_url: String
    public let user: User
    public let html_url: String
    public let url: String
}
