import Foundation
import ComposableArchitecture

nonisolated struct Breed: Equatable, Identifiable, Codable {
    let id: String
    let name: String
    let origin: String
    let temperament: String
    let description: String
    let lifeSpan: String
    let referenceImageID: String?
}

extension SharedKey where Self == FileStorageKey<IdentifiedArrayOf<Breed>>.Default {
  static var favoriteBreeds: Self {
    Self[.fileStorage(.documentsDirectory.appending(component: "user-favorites.json")),
      default: []
    ]
  }
}
