import Foundation

@MainActor
protocol GenreViewInput: AnyObject {
    func displayGenres(_ genres: [GenreDisplayItem])
}
