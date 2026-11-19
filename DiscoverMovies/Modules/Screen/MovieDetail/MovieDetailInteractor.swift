import Foundation

@MainActor
protocol MovieDetailInteractorInput: AnyObject {
    func loadInitialData()
    func loadNextReviewPageIfNeeded(currentIndex: Int)
}

@MainActor
protocol MovieDetailInteractorOutput: AnyObject {
    func movieDetailInteractorDidStartLoading(_ interactor: MovieDetailInteractorInput)
    func movieDetailInteractor(_ interactor: MovieDetailInteractorInput, didLoadTrailerURL url: URL?)
    func movieDetailInteractor(_ interactor: MovieDetailInteractorInput, didLoadReviews reviews: [Review], append: Bool)
    func movieDetailInteractorDidLoadEmptyReviews(_ interactor: MovieDetailInteractorInput)
    func movieDetailInteractor(_ interactor: MovieDetailInteractorInput, didFailWith message: String)
}

@MainActor
final class MovieDetailInteractor: MovieDetailInteractorInput {
    weak var output: MovieDetailInteractorOutput?
    private let movie: Movie
    private let service: MovieServiceProtocol
    private var currentReviewPage = 0
    private var totalReviewPages = 1
    private var isLoadingReviews = false
    private var reviews: [Review] = []
    private var trailerTask: Task<Void, Never>?
    private var reviewTask: Task<Void, Never>?

    init(movie: Movie, service: MovieServiceProtocol) {
        self.movie = movie
        self.service = service
    }

    func loadInitialData() {
        trailerTask?.cancel()
        reviewTask?.cancel()
        reviews = []
        currentReviewPage = 0
        totalReviewPages = 1
        isLoadingReviews = false
        loadTrailer()
        loadReviews()
    }

    func loadNextReviewPageIfNeeded(currentIndex: Int) {
        guard !reviews.isEmpty, currentIndex >= reviews.count - 2 else { return }
        loadReviews()
    }

    private func loadTrailer() {
        trailerTask = Task {
            do {
                let videos = try await service.fetchVideos(movieId: movie.id)
                guard !Task.isCancelled else { return }
                let trailer = videos.first {
                    $0.site.lowercased() == "youtube" && $0.type.lowercased() == "trailer"
                } ?? videos.first {
                    $0.site.lowercased() == "youtube"
                }
                let url = trailer.flatMap {
                    URL(string: "https://www.youtube.com/watch?v=\($0.key)&playsinline=1")
                }
                output?.movieDetailInteractor(self, didLoadTrailerURL: url)
            } catch {
                guard !Task.isCancelled else { return }
                output?.movieDetailInteractor(self, didLoadTrailerURL: nil)
            }
        }
    }

    private func loadReviews() {
        guard !isLoadingReviews, currentReviewPage < totalReviewPages else { return }
        let nextPage = currentReviewPage + 1
        isLoadingReviews = true
        output?.movieDetailInteractorDidStartLoading(self)
        reviewTask = Task {
            do {
                let response = try await service.fetchReviews(movieId: movie.id, page: nextPage)
                guard !Task.isCancelled else { return }
                isLoadingReviews = false
                currentReviewPage = response.page
                totalReviewPages = max(response.totalPages, response.page)
                reviews.append(contentsOf: response.results)
                if reviews.isEmpty {
                    output?.movieDetailInteractorDidLoadEmptyReviews(self)
                } else {
                    output?.movieDetailInteractor(self, didLoadReviews: reviews, append: nextPage > 1)
                }
            } catch {
                guard !Task.isCancelled else { return }
                isLoadingReviews = false
                output?.movieDetailInteractor(self, didFailWith: error.localizedDescription)
            }
        }
    }
}
