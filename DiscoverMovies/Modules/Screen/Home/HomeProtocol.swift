//
//  HomeProtocol.swift
//  DiscoverMovies
//
//  Created by Abiyyu Hilmi on 18/11/26.
//


import Foundation

protocol HomeInteractorProtocol {
    func fetchMovies() async throws -> [Movie]
}

protocol HomePresenterProtocol: ObservableObject {
    func fetchMovies() async
}

protocol HomeRouterProtocol {
    func showMovieDetail(_ movie: Movie)
}
