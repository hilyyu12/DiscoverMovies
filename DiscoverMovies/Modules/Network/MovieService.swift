import Foundation

protocol MovieServiceProtocol {
    func fetchGenres() async throws -> [Genre]
    func discoverMovies(genreId: Int, page: Int) async throws -> MovieResponse
    func searchMovie(query: String, page: Int) async throws -> MovieResponse
    func fetchReviews(movieId: Int, page: Int) async throws -> ReviewResponse
    func fetchVideos(movieId: Int) async throws -> [Video]
}

final class MovieService: MovieServiceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchGenres() async throws -> [Genre] {
        let response: GenreResponse = try await networkService.request("/genre/movie/list", queryItems: [])
        return response.genres
    }

    func discoverMovies(genreId: Int, page: Int) async throws -> MovieResponse {
        try await networkService.request("/discover/movie", queryItems: [
            URLQueryItem(name: "with_genres", value: String(genreId)),
            URLQueryItem(name: "page", value: String(page))
        ])
    }

    func searchMovie(query: String, page: Int) async throws -> MovieResponse {
        try await networkService.request("/search/movie", queryItems: [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page))
        ])
    }

    func fetchReviews(movieId: Int, page: Int) async throws -> ReviewResponse {
        try await networkService.request("/movie/\(movieId)/reviews", queryItems: [
            URLQueryItem(name: "page", value: String(page))
        ])
    }

    func fetchVideos(movieId: Int) async throws -> [Video] {
        let response: VideoResponse = try await networkService.request("/movie/\(movieId)/videos", queryItems: [])
        return response.results
    }
}
