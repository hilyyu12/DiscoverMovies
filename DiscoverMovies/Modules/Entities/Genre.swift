import Foundation

struct Genre: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
}

struct GenreResponse: Decodable {
    let genres: [Genre]
}
