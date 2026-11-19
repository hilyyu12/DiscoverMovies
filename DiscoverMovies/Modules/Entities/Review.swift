import Foundation

struct Review: Decodable, Identifiable {
    let id: String
    let author: String
    let content: String
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, author, content
        case createdAt = "created_at"
    }
}

struct ReviewResponse: Decodable {
    let page: Int
    let results: [Review]
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
    }
}
