import Mint
import Vapor

//struct GitHubLinkResponse: Content {
//    let issueUrl: String
//    let linkRequest: AccountLinkRequest
//}
//
//struct GitHubLinkInput: Content {
//    let githubUsername: String
//    let source: String
//    let id: String
//    let username: String
//}


//final class GitHubLinkBuilder {
//    private let worker: DatabaseWorker
//    private let github: GitHub.Network
//    private let vault: Vault
//
//    private let input: GitHubLinkInput
//
//    private init(
//        _ worker: DatabaseWorker,
//        input: GitHubLinkInput
//        ) {
//        self.worker = worker
//        self.github = .init(worker, token: PENNY_GITHUB_TOKEN)
//        self.vault = .init(worker)
//
//        self.input = input
//    }
//
//    private func run() throws -> Future<GitHubLinkResponse> {
//        let issue = try postGitHubIssue()
//        let user = try githubUser()
//        return issue.and(user).flatMap(to: GitHubLinkResponse.self, makeLinkRequest)
//    }
//
//    private func postGitHubIssue() throws -> Future<GitHub.Issue> {
//        fatalError()
////        var verification = "Hey there, @\(input.githubUsername), "
////        verification += "\(input.username) from \(input.source), wants to link this GitHub account."
////        verification += "\n\n"
////        verification += "Continue:\n"
////        verification += "Comment on this issue with the word, `verify`."
////        verification += "\n\n"
////        verification += "**THAT'S NOT ME!**\n"
////        verification += "Comment on this issue with the word, `fraud`."
////        verification += "\n\n"
////        verification += "Something Else:\n"
////        verification += "Type anything else to close this issue."
////
////        return try github.postIssue(
////            user: "penny-coin",
////            repo: "validation",
////            title: "Verifying: \(input.githubUsername)",
////            body: verification
////        )
//    }
//
//    private func githubUser() throws -> Future<GitHub.User> {
//        return try github.user(login: input.githubUsername)
//    }
//
//    private func makeLinkRequest(issue: GitHub.Issue, user: GitHub.User) throws -> Future<GitHubLinkResponse> {
//        let link = try vault.linkRequests.create(
//            initiationSource: input.source,
//            initiationId: input.id,
//            requestedSource: user.externalSource,
//            requestedId: user.externalId,
//            reference: issue.id.description
//        )
//
//        let msg = makeMessage(issue: issue)
//        return link.map { GitHubLinkResponse(message: msg, linkRequest: $0) }
//    }
//
//    private func makeMessage(issue: GitHub.Issue) -> String {
//        return "Visit \(issue.html_url) to connect your GitHub account."
//    }
//
//    static func linkGitHub(on worker: DatabaseWorker, with input: GitHubLinkInput) throws -> Future<GitHubLinkResponse> {
//        let worker = self.init(
//            worker,
//            input: input
//        )
//        return try worker.run()
//
//    }
//}
