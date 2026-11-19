//
//  APIConfig.swift
//  DiscoverMovies
//
//  Created by Abiyyu Hilmi on 18/11/26.
//


import Foundation

enum APIConfig {

    static let baseURL = "https://api.themoviedb.org/3"

    static var accessToken: String {
        guard let configuredToken = Bundle.main.object(
            forInfoDictionaryKey: "TMDB_ACCESS_TOKEN"
        ) as? String,
        !configuredToken.isEmpty else {
            fatalError("TMDB_ACCESS_TOKEN is missing")
        }

        let token = configuredToken.trimmingCharacters(in: .whitespacesAndNewlines)
        if token.count >= 2, token.first == "\"", token.last == "\"" {
            return String(token.dropFirst().dropLast())
        }
        return token
    }
}
