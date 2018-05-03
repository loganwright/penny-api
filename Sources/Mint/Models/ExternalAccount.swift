/// Used to link external accounts internally
public protocol ExternalAccount {
    var externalSource: String { get }
    var externalId: String { get }
}
