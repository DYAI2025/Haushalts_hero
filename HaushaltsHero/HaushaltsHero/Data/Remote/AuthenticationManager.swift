// ============================================
// Authentication Manager
// ============================================

import Foundation

class AuthenticationManager {
    // MARK: - Properties

    static let shared = AuthenticationManager()

    private let userDefaults = UserDefaults.standard
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"

    var accessToken: String? {
        get { userDefaults.string(forKey: accessTokenKey) }
        set { userDefaults.set(newValue, forKey: accessTokenKey) }
    }

    var refreshToken: String? {
        get { userDefaults.string(forKey: refreshTokenKey) }
        set { userDefaults.set(newValue, forKey: refreshTokenKey) }
    }

    var isAuthenticated: Bool {
        accessToken != nil
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - Authentication Methods

    func register(email: String, password: String) async throws -> User {
        let body = RegisterRequest(email: email, password: password)
        let response: AuthResponse = try await APIClient.shared.post("/auth/register", body: body)

        // Save tokens
        accessToken = response.accessToken
        refreshToken = response.refreshToken

        return response.user
    }

    func login(email: String, password: String) async throws -> User {
        let body = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await APIClient.shared.post("/auth/login", body: body)

        // Save tokens
        accessToken = response.accessToken
        refreshToken = response.refreshToken

        return response.user
    }

    func logout() async throws {
        guard let refreshToken = refreshToken else { return }

        let body = RefreshTokenRequest(refreshToken: refreshToken)
        try? await APIClient.shared.post("/auth/logout", body: body) as EmptyResponse

        // Clear tokens
        accessToken = nil
        self.refreshToken = nil
    }

    func refreshAccessToken() async -> Bool {
        guard let refreshToken = refreshToken else { return false }

        do {
            let body = RefreshTokenRequest(refreshToken: refreshToken)
            let response: TokenResponse = try await APIClient.shared.post("/auth/refresh", body: body)

            // Update tokens
            accessToken = response.accessToken
            self.refreshToken = response.refreshToken

            return true
        } catch {
            // Refresh failed - clear tokens
            accessToken = nil
            self.refreshToken = nil
            return false
        }
    }

    func getCurrentUser() async throws -> User {
        try await APIClient.shared.get("/users/me")
    }
}

// MARK: - Request Models

struct RegisterRequest: Encodable {
    let email: String
    let password: String
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

// MARK: - Response Models

struct AuthResponse: Decodable {
    let user: User
    let accessToken: String
    let refreshToken: String
}

struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

struct User: Decodable, Identifiable {
    let id: String
    let email: String
    let createdAt: Date
    let updatedAt: Date
}
