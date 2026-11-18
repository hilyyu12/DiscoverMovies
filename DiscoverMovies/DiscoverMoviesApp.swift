//
//  DiscoverMoviesApp.swift
//  DiscoverMovies
//
//  Created by Abiyyu Hilmi on 18/11/26.
//

import SwiftUI

@main
struct DiscoverMoviesApp: App {
    private let presenter: HomePresenter
    init() {
        let networkService = NetworkService()
        let interactor = HomeInteractor(
            networkService: networkService
        )
        self.presenter = HomePresenter(
            interactor: interactor
        )
    }

    var body: some Scene {
        WindowGroup {
            HomeView(presenter: presenter)
        }
    }
}
