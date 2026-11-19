import Foundation

struct MovieRowDisplayItem: Equatable, Identifiable {
    let id: Int
    let title: String
    let posterURL: URL?
}
