//
//  IssueApi.swift
//  GitHub
//
//  Created by Logan Wright on 4/11/18.
//

import Foundation
import Vapor

public struct PullRequest: Content {
    public let merged: Bool
    public let author_association: String // != OWNER
    public let user: User
    public let merged_by: User?
    public let number: Int
    public let review_comments_url: String
}
