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
        guard let token = Bundle.main.object(
            forInfoDictionaryKey: "TMDB_ACCESS_TOKEN"
        ) as? String,
        !token.isEmpty else {
            fatalError("TMDB_ACCESS_TOKEN is missing")
        }

        return token
    }
}
