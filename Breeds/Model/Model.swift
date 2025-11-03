import Foundation

struct Breed: Equatable, Identifiable, Codable {
    let id: String
    let name: String
    let origin: String
    let temperament: String
    let description: String
    let lifeSpan: String
    let referenceImageID: String?
    var isFavorite: Bool
}
