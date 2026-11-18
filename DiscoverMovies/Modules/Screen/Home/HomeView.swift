//
//  HomeView.swift
//  DiscoverMovies
//
//  Created by Abiyyu Hilmi on 18/11/26.
//



import SwiftUI

struct HomeView: View {

    @StateObject private var presenter: HomePresenter

    init(presenter: HomePresenter) {
        _presenter = StateObject(
            wrappedValue: presenter
        )
    }

    var body: some View {

        NavigationStack {

            Group {

                if presenter.isLoading {
                    ProgressView("Loading movies...")

                } else if let error = presenter.errorMessage {
                    ContentUnavailableView(
                        "Something went wrong",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )

                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ],
                            spacing: 16
                        ) {

                            ForEach(presenter.movies) { movie in

                                VStack(alignment: .leading) {

                                    AsyncImage(
                                        url: movie.posterURL
                                    ) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(
                                                contentMode: .fill
                                            )
                                    } placeholder: {
                                        Rectangle()
                                            .fill(.gray.opacity(0.2))
                                    }
                                    .frame(height: 230)
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 12
                                        )
                                    )

                                    Text(movie.title)
                                        .font(.headline)
                                        .lineLimit(2)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Discover")
            .task {
                await presenter.fetchMovies()
            }
        }
    }
}
