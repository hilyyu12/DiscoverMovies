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

        components?.queryItems = queryItems

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

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

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

        return try JSONDecoder().decode(T.self, from: data)
    }
}
