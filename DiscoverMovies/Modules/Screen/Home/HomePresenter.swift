import SwiftUI

@MainActor
final class HomePresenter: ObservableObject, MovieListViewOutput {
    @Published private(set) var movies: [MovieRowDisplayItem] = []
    @Published private(set) var genres: [GenreDisplayItem] = []
    @Published private(set) var isLoadingFirstPage = false
    @Published private(set) var isLoadingNextPage = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var emptyMessage: String?

    private let interactor: MovieListInteractorInput
    private let router: MovieListRouterInput
    private var genrePresenter: GenrePresenterInput?
    private var selectedGenre: Genre?
    private var rawMovies: [Movie] = []
    private var currentQuery = ""
    private var hasLoaded = false

    init(interactor: MovieListInteractorInput, router: MovieListRouterInput) {
        self.interactor = interactor
        self.router = router
    }

    func setGenrePresenter(_ genrePresenter: GenrePresenterInput) {
        self.genrePresenter = genrePresenter
    }

    func viewDidLoad() {
        guard !hasLoaded else { return }
        hasLoaded = true
        genrePresenter?.loadGenres()
    }

    func didUpdateSearchText(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        currentQuery = trimmedText
        if trimmedText.isEmpty || trimmedText.count >= 3 {
            interactor.loadMovies(genreId: selectedGenre?.id, query: trimmedText, reset: true)
        }
    }

    func didSelectGenre(at index: Int) {
        genrePresenter?.selectGenre(at: index)
    }

    func didSelectMovie(at index: Int) {
        guard movies.indices.contains(index) else { return }
        guard rawMovies.indices.contains(index) else { return }
        router.navigateToMovieDetail(movie: rawMovies[index])
    }

    func didScrollToItem(at index: Int) {
        interactor.loadNextPageIfNeeded(currentIndex: index)
    }

    func retry() {
        if genres.isEmpty {
            genrePresenter?.loadGenres()
        } else {
            interactor.loadMovies(genreId: selectedGenre?.id, query: currentQuery, reset: movies.isEmpty)
        }
    }
}

extension HomePresenter: GenrePresenterOutput {
    func genrePresenterDidStartLoading(_ presenter: GenrePresenterInput) {
        displayLoading(isFirstPage: true)
    }

    func genrePresenter(_ presenter: GenrePresenterInput, didUpdate genres: [GenreDisplayItem], selectedGenre: Genre?) {
        self.selectedGenre = selectedGenre
        displayGenres(genres)
        interactor.loadMovies(genreId: selectedGenre?.id, query: currentQuery, reset: true)
    }

    func genrePresenter(_ presenter: GenrePresenterInput, didFailWith message: String) {
        displayError(message)
    }
}

extension HomePresenter: MovieListInteractorOutput {
    func movieListInteractorDidStartLoading(_ interactor: MovieListInteractorInput, isFirstPage: Bool) {
        displayLoading(isFirstPage: isFirstPage)
    }

    func movieListInteractor(_ interactor: MovieListInteractorInput, didLoad movies: [Movie], append: Bool) {
        rawMovies = movies
        displayMovies(movies.map { MovieRowDisplayItem(id: $0.id, title: $0.title, posterURL: $0.posterURL) })
    }

    func movieListInteractorDidLoadEmptyMovies(_ interactor: MovieListInteractorInput) {
        displayEmptyState("No movies found")
    }

    func movieListInteractor(_ interactor: MovieListInteractorInput, didFailWith message: String) {
        displayError(message)
    }
}

extension HomePresenter: MovieListViewInput, GenreViewInput {
    func displayLoading(isFirstPage: Bool) {
        errorMessage = nil
        emptyMessage = nil
        if isFirstPage {
            movies = []
            rawMovies = []
            isLoadingFirstPage = true
            isLoadingNextPage = false
        } else {
            isLoadingNextPage = true
        }
    }

    func displayMovies(_ movies: [MovieRowDisplayItem]) {
        self.movies = movies
        isLoadingFirstPage = false
        isLoadingNextPage = false
        errorMessage = nil
        emptyMessage = nil
    }

    func displayGenres(_ genres: [GenreDisplayItem]) {
        self.genres = genres
    }

    func displayEmptyState(_ message: String) {
        movies = []
        rawMovies = []
        isLoadingFirstPage = false
        isLoadingNextPage = false
        errorMessage = nil
        emptyMessage = message
    }

    func displayError(_ message: String) {
        isLoadingFirstPage = false
        isLoadingNextPage = false
        errorMessage = message
    }
}
