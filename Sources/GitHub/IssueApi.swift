//
//  IssueApi.swift
//  GitHub
//
//  Created by Logan Wright on 4/11/18.
//

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
    public let title: String
    public let body: String?

    public let state: String
    public let number: Int
    public let comments_url: String
    public let user: User
}
