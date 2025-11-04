import ComposableArchitecture
import SwiftUI
@testable import Breeds


enum MockData {
    
    static func makeBreed(id: String, isFavorite: Bool = false) -> Breed {
        return Breed(
            id: id,
            name: "Breed \(id)",
            origin: "Origin \(id)",
            temperament: "Temperament \(id)",
            description: "Description \(id)",
            lifeSpan: "12-15",
            referenceImageID: nil,
            isFavorite: isFavorite
        )
    }
    
    static let breed1 = MockData.makeBreed(id: "1")
    static let breed2 = MockData.makeBreed(id: "2")
    static let favoritedBreed1 = MockData.makeBreed(id: "1", isFavorite: true)

    static func makeState(
        breeds: [Breed] = [],
        favorites: [Breed] = []
    ) -> BreedListFeature.State {
        var state = BreedListFeature.State()
        state.breeds = IdentifiedArray(uniqueElements: breeds)
        state.$favoriteBreeds.withLock { $0 = IdentifiedArray(uniqueElements: favorites) }
        return state
    }
}

