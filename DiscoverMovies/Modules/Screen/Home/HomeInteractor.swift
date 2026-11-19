import Foundation

@MainActor
final class HomeInteractor: MovieListInteractorInput {
    weak var output: MovieListInteractorOutput?
    private let service: MovieServiceProtocol
    private var currentGenreId: Int?
    private var currentQuery = ""
    private var currentPage = 0
    private var totalPages = 1
    private var currentMovies: [Movie] = []
    private var isLoading = false
    private var requestID = 0
    private var task: Task<Void, Never>?

    init(service: MovieServiceProtocol) {
        self.service = service
    }

    func loadMovies(genreId: Int?, query: String?, reset: Bool) {
        let normalizedQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let shouldReset = reset || currentGenreId != genreId || currentQuery != normalizedQuery
        if shouldReset {
            requestID += 1
            task?.cancel()
            isLoading = false
            currentGenreId = genreId
            currentQuery = normalizedQuery
            currentPage = 0
            totalPages = 1
            currentMovies = []
        }
        guard !isLoading else { return }
        guard currentGenreId != nil || !currentQuery.isEmpty else {
            output?.movieListInteractorDidLoadEmptyMovies(self)
            return
        }
        guard currentPage < totalPages else { return }

        let nextPage = currentPage + 1
        let activeRequestID = requestID
        let genreID = currentGenreId
        let searchQuery = currentQuery
        isLoading = true
        output?.movieListInteractorDidStartLoading(self, isFirstPage: nextPage == 1)

        task = Task {
            do {
                let response: MovieResponse
                if searchQuery.isEmpty, let genreID {
                    response = try await service.discoverMovies(genreId: genreID, page: nextPage)
                } else {
                    response = try await service.searchMovie(query: searchQuery, page: nextPage)
                }
                guard !Task.isCancelled, activeRequestID == requestID else { return }
                isLoading = false
                currentPage = response.page
                totalPages = max(response.totalPages, response.page)
                currentMovies.append(contentsOf: response.results)
                if currentMovies.isEmpty {
                    output?.movieListInteractorDidLoadEmptyMovies(self)
                } else {
                    output?.movieListInteractor(self, didLoad: currentMovies, append: nextPage > 1)
                }
            } catch {
                guard !Task.isCancelled, activeRequestID == requestID else { return }
                isLoading = false
                output?.movieListInteractor(self, didFailWith: error.localizedDescription)
            }
        }
    }

    func loadNextPageIfNeeded(currentIndex: Int) {
        guard !currentMovies.isEmpty, currentIndex >= currentMovies.count - 4 else { return }
        loadMovies(genreId: currentGenreId, query: currentQuery, reset: false)
    }
}
