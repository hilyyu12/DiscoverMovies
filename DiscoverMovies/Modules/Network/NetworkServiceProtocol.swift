//
//  NetworkServiceProtocol.swift
//  DiscoverMovies
//
//  Created by Abiyyu Hilmi on 18/11/26.
//



import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        _ endpoint: String,
        queryItems: [URLQueryItem]
    ) async throws -> T
}
