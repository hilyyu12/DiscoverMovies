//
//  MovieResponse.swift
//  DiscoverMovies
//
//  Created by Abiyyu Hilmi on 18/11/26.
//



import Foundation

struct MovieResponse: Decodable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
