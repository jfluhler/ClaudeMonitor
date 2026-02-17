import Foundation
import Security

enum KeychainError: Error, LocalizedError {
    case itemNotFound
    case unexpectedData
    case unhandledError(status: OSStatus)
    case tokenParsingFailed

    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Claude Code credentials not found in Keychain. Make sure Claude Code is installed and you're logged in."
        case .unexpectedData:
            return "Unexpected credential data format in Keychain."
        case .unhandledError(let status):
            return "Keychain error (OSStatus \(status))."
        case .tokenParsingFailed:
            return "Failed to parse OAuth token from Claude Code credentials."
        }
    }
}

final class KeychainService {
    static let shared = KeychainService()
    private let serviceName = "Claude Code-credentials"

    private init() {}

    func getOAuthToken() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }

        guard let data = result as? Data,
              let jsonString = String(data: data, encoding: .utf8)
        else {
            throw KeychainError.unexpectedData
        }

        guard let jsonData = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let claudeAiOauth = json["claudeAiOauth"] as? [String: Any],
              let accessToken = claudeAiOauth["accessToken"] as? String
        else {
            throw KeychainError.tokenParsingFailed
        }

        return accessToken
    }
}
