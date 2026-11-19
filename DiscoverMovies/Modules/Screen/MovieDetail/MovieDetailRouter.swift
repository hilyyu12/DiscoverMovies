import SwiftUI

enum MovieDetailRouter {
    @MainActor
    static func makeModule(movie: Movie, service: MovieServiceProtocol) -> MovieDetailView {
        let interactor = MovieDetailInteractor(movie: movie, service: service)
        let presenter = MovieDetailPresenter(interactor: interactor, movie: movie)
        interactor.output = presenter
        return MovieDetailView(presenter: presenter)
    }
}
