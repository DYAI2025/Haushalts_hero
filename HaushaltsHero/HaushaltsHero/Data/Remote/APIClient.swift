// ============================================
// API Client for Backend Communication
// ============================================

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
    case unauthorized
    case notFound
    case serverError(String)
}

class APIClient {
    // MARK: - Properties

    static let shared = APIClient()

    private let session: URLSession
    private var baseURL: String {
        // Development: Use localhost
        // Production: Replace with actual API URL
        #if DEBUG
        return "http://localhost:3000/api/v1"
        #else
        return "https://api.haushalts-hero.com/api/v1"
        #endif
    }

    private var authManager: AuthenticationManager {
        AuthenticationManager.shared
    }

    // MARK: - Initialization

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - HTTP Methods

    func get<T: Decodable>(_ endpoint: String) async throws -> T {
        try await request(endpoint, method: "GET")
    }

    func post<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        try await request(endpoint, method: "POST", body: body)
    }

    func put<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        try await request(endpoint, method: "PUT", body: body)
    }

    func patch<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        try await request(endpoint, method: "PATCH", body: body)
    }

    func delete(_ endpoint: String) async throws {
        let _: EmptyResponse = try await request(endpoint, method: "DELETE")
    }

    // MARK: - Core Request Method

    private func request<T: Decodable, B: Encodable>(
        _ endpoint: String,
        method: String,
        body: B? = nil as EmptyBody?
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authorization header if token exists
        if let accessToken = authManager.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        // Encode body if provided
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw APIError.encodingError(error)
            }
        }

        // Perform request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Handle status codes
        switch httpResponse.statusCode {
        case 200...299:
            // Success - decode response
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }

        case 401:
            // Unauthorized - try to refresh token
            if await authManager.refreshAccessToken() {
                // Retry request with new token
                return try await request(endpoint, method: method, body: body)
            } else {
                throw APIError.unauthorized
            }

        case 404:
            throw APIError.notFound

        case 400...499:
            // Client error - try to decode error message
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.error.message)
            }
            throw APIError.httpError(httpResponse.statusCode)

        case 500...599:
            // Server error
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.error.message)
            }
            throw APIError.httpError(httpResponse.statusCode)

        default:
            throw APIError.httpError(httpResponse.statusCode)
        }
    }

    // MARK: - File Upload

    func uploadPhoto(_ imageData: Data) async throws -> PhotoResponse {
        guard let url = URL(string: baseURL + "/photos/upload") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Add authorization header
        if let accessToken = authManager.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add photo data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        // Perform request
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(PhotoResponse.self, from: data)
    }
}

// MARK: - Helper Types

struct EmptyBody: Encodable {}
struct EmptyResponse: Decodable {}

struct ErrorResponse: Decodable {
    let error: ErrorDetail

    struct ErrorDetail: Decodable {
        let code: String
        let message: String
        let details: [String: String]?
    }
}

struct PhotoResponse: Decodable {
    let id: String
    let userId: String
    let url: String
    let path: String
    let size: Int
    let mimeType: String
    let createdAt: Date
}
