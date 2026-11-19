import SwiftUI

@MainActor
final class MovieDetailPresenter: ObservableObject, MovieDetailViewOutput {
    @Published private(set) var movieItem: MovieDetailDisplayItem?
    @Published private(set) var trailerURL: URL?
    @Published private(set) var trailerUnavailable = false
    @Published private(set) var reviews: [ReviewDisplayItem] = []
    @Published private(set) var reviewStateMessage: String?
    @Published private(set) var isLoadingReviews = false

    private let interactor: MovieDetailInteractorInput
    private let movie: Movie
    private var hasLoaded = false

    init(interactor: MovieDetailInteractorInput, movie: Movie) {
        self.interactor = interactor
        self.movie = movie
    }

    func viewDidLoad() {
        guard !hasLoaded else { return }
        hasLoaded = true
        displayMovie(MovieDetailDisplayItem(
            title: movie.title,
            ratingText: String(format: "Rating %.1f/10", movie.voteAverage),
            overviewText: movie.overview.isEmpty ? "No overview available" : movie.overview,
            posterURL: movie.posterURL
        ))
        interactor.loadInitialData()
    }

    func didScrollToReview(at index: Int) {
        interactor.loadNextReviewPageIfNeeded(currentIndex: index)
    }
}

extension MovieDetailPresenter: MovieDetailInteractorOutput {
    func movieDetailInteractorDidStartLoading(_ interactor: MovieDetailInteractorInput) {
        displayLoading()
    }

    func movieDetailInteractor(_ interactor: MovieDetailInteractorInput, didLoadTrailerURL url: URL?) {
        displayTrailer(url: url)
    }

    func movieDetailInteractor(_ interactor: MovieDetailInteractorInput, didLoadReviews reviews: [Review], append: Bool) {
        displayReviews(reviews.map { ReviewDisplayItem(id: $0.id, author: $0.author, content: $0.content) })
    }

    func movieDetailInteractorDidLoadEmptyReviews(_ interactor: MovieDetailInteractorInput) {
        displayEmptyReviews()
    }

    func movieDetailInteractor(_ interactor: MovieDetailInteractorInput, didFailWith message: String) {
        displayError(message)
    }
}

extension MovieDetailPresenter: MovieDetailViewInput {
    func displayLoading() {
        isLoadingReviews = true
        reviewStateMessage = nil
    }

    func displayMovie(_ item: MovieDetailDisplayItem) {
        movieItem = item
    }

    func displayTrailer(url: URL?) {
        trailerURL = url
        trailerUnavailable = url == nil
    }

    func displayReviews(_ reviews: [ReviewDisplayItem]) {
        self.reviews = reviews
        isLoadingReviews = false
        reviewStateMessage = nil
    }

    func displayEmptyReviews() {
        reviews = []
        isLoadingReviews = false
        reviewStateMessage = "No reviews yet"
    }

    func displayError(_ message: String) {
        isLoadingReviews = false
        reviewStateMessage = message
    }
}
