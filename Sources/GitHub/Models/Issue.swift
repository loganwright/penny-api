import Foundation
import Vapor

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
