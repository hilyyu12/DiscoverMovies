//
//  Movie.swift
//  DiscoverMovies
//
//  Created by Abiyyu Hilmi on 18/11/26.
//


import Foundation

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let releaseDate: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }

    var posterURL: URL? {
        guard let posterPath else { return nil }

        return URL(
            string: "https://image.tmdb.org/t/p/w500\(posterPath)"
        )
    }
    
    var backdropURL: URL? {
        guard let backdropPath else { return nil }
        
        return URL(
            string: "https://image.tmdb.org/t/p/w1280\(backdropPath)"
        )
    }
}
