// MARK: Coin Suffix

let validSuffixes = [
    "++",
    ":coin:",
    "+= 1",
    "+ 1",
    "advance(by: 1)",
    "successor()",
    "👍",
    ":+1:",
    ":thumbsup:",
    "🙌",
    ":raised_hands:",
    "🚀",
    ":rocket:",
    "thanks",
    "thanks!",
    "thank you",
    "thank you!",
    "thx",
    "thx!"
]

extension String {
    var hasCoinSuffix: Bool {
        for suffix in validSuffixes where hasSuffix(suffix) {
            return true
        }
        return false
    }
}

func shouldGiftCoin(in msg: String) -> Bool {
    return msg.trimmedWhitespace().hasCoinSuffix
}

// MARK: WhiteSpace

extension String {
    func trimmedWhitespace() -> String {
        var characters = Substring(self)
        while characters.first?.isWhitespace == true {
            characters.removeFirst()
        }
        while characters.last?.isWhitespace == true {
            characters.removeLast()
        }

        return String(characters)
    }
}

extension Character {
    fileprivate var isWhitespace: Bool {
        switch self {
        case " ", "\t", "\n", "\r", "\r\n":
            return true
        default:
            return false
        }
    }
}
