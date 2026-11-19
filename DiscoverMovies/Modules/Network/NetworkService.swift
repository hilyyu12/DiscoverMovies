//
//  NetworkService.swift
//  DiscoverMovies
//
//  Created by Abiyyu Hilmi on 18/11/26.
//


import Foundation

enum NetworkError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response."

        case .httpError(let statusCode, let message):
            return "HTTP Error \(statusCode): \(message)"
        }
    }
}

final class NetworkService: NetworkServiceProtocol {

    func request<T: Decodable>(
        _ endpoint: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {

        var components = URLComponents(
            string: APIConfig.baseURL + endpoint
        )

        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        request.setValue(
            "Bearer \(APIConfig.accessToken)",
            forHTTPHeaderField: "Authorization"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        #if DEBUG
        let logID = String(UUID().uuidString.prefix(8))
        logRequest(request, id: logID)
        #endif

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            #if DEBUG
            print("[Network \(logID)] Transport error: \(error)")
            #endif
            throw error
        }

        #if DEBUG
        logResponse(response, data: data, id: logID)
        #endif

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {

            let message = String(
                data: data,
                encoding: .utf8
            ) ?? "Unknown server error"

            throw NetworkError.httpError(
                statusCode: httpResponse.statusCode,
                message: message
            )
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            #if DEBUG
            print("[Network \(logID)] Decode error: \(error)")
            #endif
            throw error
        }
    }

    #if DEBUG
    private func logRequest(_ request: URLRequest, id: String) {
        let headers = (request.allHTTPHeaderFields ?? [:])
            .map { name, value in
                let loggedValue = name.caseInsensitiveCompare("Authorization") == .orderedSame
                    ? "Bearer <redacted>"
                    : value
                return "\(name): \(loggedValue)"
            }
            .sorted()
            .joined(separator: "\n")
        let body = request.httpBody.flatMap { String(data: $0, encoding: .utf8) } ?? "<none>"
        print("[Network \(id)] Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "<invalid URL>")\nHeaders:\n\(headers)\nBody:\n\(body)")
    }

    private func logResponse(_ response: URLResponse, data: Data, id: String) {
        guard let httpResponse = response as? HTTPURLResponse else {
            print("[Network \(id)] Non-HTTP response: \(response)")
            return
        }
        let headers = httpResponse.allHeaderFields
            .map { "\($0.key): \($0.value)" }
            .sorted()
            .joined(separator: "\n")
        let body = String(data: data, encoding: .utf8) ?? "<non-UTF-8 body, \(data.count) bytes>"
        print("[Network \(id)] Response: HTTP \(httpResponse.statusCode) \(httpResponse.url?.absoluteString ?? "<unknown URL>")\nHeaders:\n\(headers)\nBody:\n\(body)")
    }
    #endif
}
