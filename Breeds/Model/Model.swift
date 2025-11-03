import Foundation

struct Breed: Equatable, Identifiable, Codable {
    let id: String
    let name: String
    let origin: String
    let temperament: String
    let description: String
    let lifeSpan: String
    let referenceImageID: String?
    let isFavorite: Bool
}

extension Breed {
extension BreedDTO {
    var breed: Breed {
        .init(
        self.id = dto.id
        self.name = dto.name
        self.origin = dto.origin
        self.temperament = dto.temperament
        self.description = dto.description
        self.lifeSpan = dto.lifeSpan
        self.referenceImageID = dto.referenceImageID
        self.isFavorite = false
        )
    }
}
}
