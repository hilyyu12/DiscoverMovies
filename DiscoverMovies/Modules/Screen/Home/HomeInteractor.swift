//
//  HomeInteractor.swift
//  DiscoverMovies
//
//  Created by Abiyyu Hilmi on 18/11/26.
//


import Foundation


import Foundation

final class HomeInteractor: HomeInteractorProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchMovies() async throws -> [Movie] {

        let response: MovieResponse = try await networkService.request(
            "/discover/movie",
            queryItems: [
                URLQueryItem(name: "with_genres", value: "\(genreId)"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        )

        return response.results
    }
}

