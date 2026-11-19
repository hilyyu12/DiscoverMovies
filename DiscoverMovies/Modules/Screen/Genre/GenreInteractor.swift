import Foundation

@MainActor
protocol GenreInteractorInput: AnyObject {
    func fetchGenres()
}

@MainActor
protocol GenreInteractorOutput: AnyObject {
    func genreInteractor(_ interactor: GenreInteractorInput, didLoad genres: [Genre])
    func genreInteractor(_ interactor: GenreInteractorInput, didFailWith message: String)
}

@MainActor
final class GenreInteractor: GenreInteractorInput {
    weak var output: GenreInteractorOutput?
    private let service: MovieServiceProtocol
    private var task: Task<Void, Never>?

    init(service: MovieServiceProtocol) {
        self.service = service
    }

    func fetchGenres() {
        task?.cancel()
        task = Task {
            do {
                let genres = try await service.fetchGenres()
                guard !Task.isCancelled else { return }
                output?.genreInteractor(self, didLoad: genres)
            } catch {
                guard !Task.isCancelled else { return }
                output?.genreInteractor(self, didFailWith: error.localizedDescription)
            }
        }
    }
}
