import Foundation

struct Breed: Equatable, Identifiable, Codable {
    let id: String
    let name: String
    let origin: String?
    let temperament: String?
    let description: String?
    let life_span: String?
    let reference_image_id: String?
    let isFavorite: Bool?
}
