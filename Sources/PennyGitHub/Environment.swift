import Vapor
import Foundation

// MARK: WebHook URL

let GITHUB_WEBHOOK_URL = "GITHUB_WEBHOOK_URL".or("https://penny-test.ngrok.io/github-webhook")
let GITHUB_WEBHOOK_SECRET = "GITHUB_WEBHOOK_SECRET".or("b36abd70-915b-46eb-88ec-aabcdfdad208")

// MARK: Validation WebHook URL

let GITHUB_VALIDATION_WEBHOOK_URL = "GITHUB_VALIDATION_WEBHOOK_URL".or("https://penny-test.ngrok.io/github-validation-webhook")
let GITHUB_VALIDATION_WEBHOOK_SECRET = "GITHUB_VALIDATION_WEBHOOK_SECRET".or("b36abd70-915b-46eb-88ec-aabcdfdad208")

// MARK: Validation Repo

let GITHUB_VALIDATION_REPO_OWNER = "GITHUB_VALIDATION_REPO_OWNER".or("penny-coin-test")
let GITHUB_VALIDATION_REPO_NAME = "GITHUB_VALIDATION_REPO_NAME".or("validation")

// MARK: Organization

let GITHUB_ORG = "GITHUB_ORG".or("penny-test-org")

// MARK: Internal Communication

let PENNY_API_TOKEN = "PENNY_API_TOKEN".or("tester")
let PENNY_API_BASE_URL = "PENNY_API_BASE_URL".or("http://localhost:8080")

// TODO: Regenerate and hide

let GITHUB_API_TOKEN = "GITHUB_API_TOKEN".or(nil)

fileprivate extension String {
    func or(_ backup: String?) -> String {
        let val = Environment.get(self) ?? backup
        if let val = val { return val }
        else {
            fatalError("Missing environment variable: \(self)")
        }
    }
}
