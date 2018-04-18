
//let foo = [
//    "login": "octocat",
//    "id": 1,
//    "avatar_url": "https://github.com/images/error/octocat_happy.gif",
//    "gravatar_id": "",
//    "url": "https://api.github.com/users/octocat",
//    "html_url": "https://github.com/octocat",
//    "followers_url": "https://api.github.com/users/octocat/followers",
//    "following_url": "https://api.github.com/users/octocat/following{/other_user}",
//    "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
//    "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
//    "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
//    "organizations_url": "https://api.github.com/users/octocat/orgs",
//    "repos_url": "https://api.github.com/users/octocat/repos",
//    "events_url": "https://api.github.com/users/octocat/events{/privacy}",
//    "received_events_url": "https://api.github.com/users/octocat/received_events",
//    "type": "User",
//    "site_admin": false
//]
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

let foo: [String: Any?] = [
    "id": 1296269,
    "owner": User.self,
    "name": "Hello-World",
    "full_name": "octocat/Hello-World",
    "description": "This your first repo!",
    "private": false,
    "fork": false,
    "url": "https://api.github.com/repos/octocat/Hello-World",
    "html_url": "https://github.com/octocat/Hello-World",
    "archive_url": "http://api.github.com/repos/octocat/Hello-World/{archive_format}{/ref}",
    "assignees_url": "http://api.github.com/repos/octocat/Hello-World/assignees{/user}",
    "blobs_url": "http://api.github.com/repos/octocat/Hello-World/git/blobs{/sha}",
    "branches_url": "http://api.github.com/repos/octocat/Hello-World/branches{/branch}",
    "clone_url": "https://github.com/octocat/Hello-World.git",
    "collaborators_url": "http://api.github.com/repos/octocat/Hello-World/collaborators{/collaborator}",
    "comments_url": "http://api.github.com/repos/octocat/Hello-World/comments{/number}",
    "commits_url": "http://api.github.com/repos/octocat/Hello-World/commits{/sha}",
    "compare_url": "http://api.github.com/repos/octocat/Hello-World/compare/{base}...{head}",
    "contents_url": "http://api.github.com/repos/octocat/Hello-World/contents/{+path}",
    "contributors_url": "http://api.github.com/repos/octocat/Hello-World/contributors",
    "deployments_url": "http://api.github.com/repos/octocat/Hello-World/deployments",
    "downloads_url": "http://api.github.com/repos/octocat/Hello-World/downloads",
    "events_url": "http://api.github.com/repos/octocat/Hello-World/events",
    "forks_url": "http://api.github.com/repos/octocat/Hello-World/forks",
    "git_commits_url": "http://api.github.com/repos/octocat/Hello-World/git/commits{/sha}",
    "git_refs_url": "http://api.github.com/repos/octocat/Hello-World/git/refs{/sha}",
    "git_tags_url": "http://api.github.com/repos/octocat/Hello-World/git/tags{/sha}",
    "git_url": "git:github.com/octocat/Hello-World.git",
    "hooks_url": "http://api.github.com/repos/octocat/Hello-World/hooks",
    "issue_comment_url": "http://api.github.com/repos/octocat/Hello-World/issues/comments{/number}",
    "issue_events_url": "http://api.github.com/repos/octocat/Hello-World/issues/events{/number}",
    "issues_url": "http://api.github.com/repos/octocat/Hello-World/issues{/number}",
    "keys_url": "http://api.github.com/repos/octocat/Hello-World/keys{/key_id}",
    "labels_url": "http://api.github.com/repos/octocat/Hello-World/labels{/name}",
    "languages_url": "http://api.github.com/repos/octocat/Hello-World/languages",
    "merges_url": "http://api.github.com/repos/octocat/Hello-World/merges",
    "milestones_url": "http://api.github.com/repos/octocat/Hello-World/milestones{/number}",
    "mirror_url": "git:git.example.com/octocat/Hello-World",
    "notifications_url": "http://api.github.com/repos/octocat/Hello-World/notifications{?since,all,participating}",
    "pulls_url": "http://api.github.com/repos/octocat/Hello-World/pulls{/number}",
    "releases_url": "http://api.github.com/repos/octocat/Hello-World/releases{/id}",
    "ssh_url": "git@github.com:octocat/Hello-World.git",
    "stargazers_url": "http://api.github.com/repos/octocat/Hello-World/stargazers",
    "statuses_url": "http://api.github.com/repos/octocat/Hello-World/statuses/{sha}",
    "subscribers_url": "http://api.github.com/repos/octocat/Hello-World/subscribers",
    "subscription_url": "http://api.github.com/repos/octocat/Hello-World/subscription",
    "svn_url": "https://svn.github.com/octocat/Hello-World",
    "tags_url": "http://api.github.com/repos/octocat/Hello-World/tags",
    "teams_url": "http://api.github.com/repos/octocat/Hello-World/teams",
    "trees_url": "http://api.github.com/repos/octocat/Hello-World/git/trees{/sha}",
    "homepage": "https://github.com",
    "language": nil,
    "forks_count": 9,
    "stargazers_count": 80,
    "watchers_count": 80,
    "size": 108,
    "default_branch": "master",
    "open_issues_count": 0,
    "topics": [
    "octocat",
    "atom",
    "electron",
    "API"
    ],
    "has_issues": true,
    "has_wiki": true,
    "has_pages": false,
    "has_downloads": true,
    "archived": false,
    "pushed_at": "2011-01-26T19:06:43Z",
    "created_at": "2011-01-26T19:01:12Z",
    "updated_at": "2011-01-26T19:14:43Z",
    "permissions": [
        "admin": false,
        "push": false,
        "pull": true
    ],
    "allow_rebase_merge": true,
    "allow_squash_merge": true,
    "allow_merge_commit": true,
    "subscribers_count": 42,
    "network_count": 0,
    "license": [
        "key": "mit",
        "name": "MIT License",
        "spdx_id": "MIT",
        "url": "https://api.github.com/licenses/mit",
        "html_url": "http://choosealicense.com/licenses/mit/"
    ]
]

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

//    // TODO: Optional?
    public let pushed_at: String?// ": "2011-01-26T19:06:43Z",
    public let created_at: String
    public let updated_at: String

    public let permissions: [String: Bool]?
//    ": [
//    "admin": false,
//    "push": false,
//    "pull": true
//    ],

    public let allow_rebase_merge: Bool?
    public let allow_squash_merge: Bool?
    public let allow_merge_commit: Bool?
    public let subscribers_count: Int?
    public let network_count: Int?

    public let license: [String: String?]?
//    ": [
//    "key": "mit",
//    "name": "MIT License",
//    "spdx_id": "MIT",
//    "url": "https://api.github.com/licenses/mit",
//    "html_url": "http://choosealicense.com/licenses/mit/"
//    ]
}
