import Foundation

@MainActor
protocol MovieListInteractorInput: AnyObject {
    func loadMovies(genreId: Int?, query: String?, reset: Bool)
    func loadNextPageIfNeeded(currentIndex: Int)
}

@MainActor
protocol MovieListInteractorOutput: AnyObject {
    func movieListInteractorDidStartLoading(_ interactor: MovieListInteractorInput, isFirstPage: Bool)
    func movieListInteractor(_ interactor: MovieListInteractorInput, didLoad movies: [Movie], append: Bool)
    func movieListInteractorDidLoadEmptyMovies(_ interactor: MovieListInteractorInput)
    func movieListInteractor(_ interactor: MovieListInteractorInput, didFailWith message: String)
}

@MainActor
protocol MovieListViewInput: AnyObject {
    func displayLoading(isFirstPage: Bool)
    func displayMovies(_ movies: [MovieRowDisplayItem])
    func displayGenres(_ genres: [GenreDisplayItem])
    func displayEmptyState(_ message: String)
    func displayError(_ message: String)
}

@MainActor
protocol MovieListViewOutput: AnyObject {
    func viewDidLoad()
    func didUpdateSearchText(_ text: String)
    func didSelectGenre(at index: Int)
    func didSelectMovie(at index: Int)
    func didScrollToItem(at index: Int)
}

@MainActor
protocol MovieListRouterInput: AnyObject {
    func navigateToMovieDetail(movie: Movie)
}
