import Testing
import ComposableArchitecture
@testable import Breeds

@Suite("Breed Cell Feature - Favorites")
@MainActor
struct BreedCellReducerTests {

    @Test func favoriteButtonTogglesStateOn() async {
        let breed = MockData.breed1
        let sharedFavorites = Shared(value: IdentifiedArrayOf<Breed>())
        let store = TestStore(
            initialState: BreedCellReducer.State(
                breed: breed,
                favoriteBreeds: sharedFavorites
            ),
            reducer: { BreedCellReducer() }
        )

        await store.send(.favoriteButtonTapped) {
            $0.$favoriteBreeds.withLock { favorites in
                favorites.append(breed)
            }
        }
    }

    @Test func favoriteButtonTogglesStateOff() async {
        let breed = MockData.breed1
        let sharedFavorites = Shared(value: IdentifiedArrayOf(uniqueElements: [breed]))

        let store = TestStore(
            initialState: BreedCellReducer.State(
                breed: breed,
                favoriteBreeds: sharedFavorites
            ),
            reducer: { BreedCellReducer() }
        )

        await store.send(.favoriteButtonTapped) {
            $0.$favoriteBreeds.withLock { favorites in
                _ = favorites.remove(id: breed.id)
            }
        }
    }
}
