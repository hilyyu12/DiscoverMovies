//
//  DiscoverMoviesApp.swift
//  DiscoverMovies
//
//  Created by Abiyyu Hilmi on 18/11/26.
//

import SwiftUI

@main
struct DiscoverMoviesApp: App {
    var body: some Scene {
        WindowGroup {
            HomeRouter.makeModule(service: MovieService(networkService: NetworkService()))
        }
    }
}
