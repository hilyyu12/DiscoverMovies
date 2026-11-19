import Foundation

enum GenreRouter {
    @MainActor
    static func makePresenter(service: MovieServiceProtocol, output: GenrePresenterOutput) -> GenrePresenterInput {
        let interactor = GenreInteractor(service: service)
        let presenter = GenrePresenter(interactor: interactor)
        interactor.output = presenter
        presenter.output = output
        return presenter
    }
}
