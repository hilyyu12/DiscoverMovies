//
//  HomePresenter.swift
//  DiscoverMovies
//
//  Created by Abiyyu Hilmi on 18/11/26.
//



import SwiftUI

@MainActor
final class HomePresenter: ObservableObject {

    @Published private(set) var movies: [Movie] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let interactor: HomeInteractorProtocol

    init(interactor: HomeInteractorProtocol) {
        self.interactor = interactor
    }

    func fetchMovies() async {

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            movies = try await interactor.fetchMovies()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
