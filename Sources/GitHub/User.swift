import Vapor

public struct User: Content {
    public let login: String
    public let id: Int
    public let avatar_url: String
    public let gravatar_id: String
    public let url: String
    public let html_url: String
    public let followers_url: String
    public let following_url: String
    public let gists_url: String
    public let starred_url: String
    public let subscriptions_url: String
    public let organizations_url: String
    public let repos_url: String
    public let events_url: String
    public let received_events_url: String
    public let type: String
    public let site_admin: Bool
}

public struct Repo: Content {
    public let id: Int
    public let owner: User
    public let name: String
    public let full_name: String
    public let description: String?
    public let `private`: Bool
    public let fork: Bool
    public let url: String
    public let html_url: String
    public let archive_url: String
    public let assignees_url: String
    public let blobs_url: String
    public let branches_url: String
    public let clone_url: String
    public let collaborators_url: String
    public let comments_url: String
    public let commits_url: String
    public let compare_url: String
    public let contents_url: String
    public let contributors_url: String
    public let deployments_url: String
    public let downloads_url: String
    public let events_url: String
    public let forks_url: String
    public let git_commits_url: String
    public let git_refs_url: String
    public let git_tags_url: String
    public let git_url: String
    public let hooks_url: String
    public let issue_comment_url: String
    public let issue_events_url: String
    public let issues_url: String
    public let keys_url: String
    public let labels_url: String
    public let languages_url: String
    public let merges_url: String
    public let milestones_url: String
    public let mirror_url: String?
    public let notifications_url: String
    public let pulls_url: String
    public let releases_url: String
    public let ssh_url: String
    public let stargazers_url: String
    public let statuses_url: String
    public let subscribers_url: String
    public let subscription_url: String
    public let svn_url: String
    public let tags_url: String
    public let teams_url: String
    public let trees_url: String
    public let homepage: String?
    public let language: String?
    public let forks_count: Int
    public let stargazers_count: Int
    public let watchers_count: Int
    public let size: Int
    public let default_branch: String
    public let open_issues_count: Int
    public let topics: [String]?
    public let has_issues: Bool
    public let has_projects: Bool
    public let has_wiki: Bool
    public let has_pages: Bool
    public let has_downloads: Bool
    public let archived: Bool

    // ": "2011-01-26T19:06:43Z",
    public let pushed_at: String?
    public let created_at: String
    public let updated_at: String

    public let permissions: [String: Bool]?

    public let allow_rebase_merge: Bool?
    public let allow_squash_merge: Bool?
    public let allow_merge_commit: Bool?
    public let subscribers_count: Int?
    public let network_count: Int?

    public let license: [String: String?]?
}
