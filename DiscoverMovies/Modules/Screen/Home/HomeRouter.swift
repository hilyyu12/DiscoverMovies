import SwiftUI

@MainActor
final class HomeRouter: ObservableObject, MovieListRouterInput {
    @Published var selectedMovie: Movie?
    private let service: MovieServiceProtocol

    private init(service: MovieServiceProtocol) {
        self.service = service
    }

    static func makeModule(service: MovieServiceProtocol) -> HomeView {
        let router = HomeRouter(service: service)
        let interactor = HomeInteractor(service: service)
        let presenter = HomePresenter(interactor: interactor, router: router)
        let genrePresenter = GenreRouter.makePresenter(service: service, output: presenter)
        presenter.setGenrePresenter(genrePresenter)
        interactor.output = presenter
        return HomeView(presenter: presenter, router: router)
    }

    func navigateToMovieDetail(movie: Movie) {
        selectedMovie = movie
    }

    func makeDetail(for movie: Movie) -> MovieDetailView {
        MovieDetailRouter.makeModule(movie: movie, service: service)
    }
}
