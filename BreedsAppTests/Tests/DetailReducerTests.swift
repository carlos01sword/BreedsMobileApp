import Testing
import ComposableArchitecture
@testable import Breeds

@Suite("Detail Feature - Favorites")
@MainActor
struct DetailReducerTests {

    @Test func favoriteButtonTogglesState() async {
        let breed = MockData.breed1
        let sharedFavorites = Shared(value: IdentifiedArrayOf<Breed>())

        let store = TestStore(
            initialState: DetailReducer.State(
                breed: breed,
                favoriteBreeds: sharedFavorites
            ),
            reducer: { DetailReducer() }
        )

        // Add to favorites
        await store.send(.favoriteButtonTapped) {
            $0.$favoriteBreeds.withLock { favorites in
                favorites.append(breed)
            }
        }

        // Remove from favorites
        await store.send(.favoriteButtonTapped) {
            $0.$favoriteBreeds.withLock { favorites in
                _ = favorites.remove(id: breed.id)
            }
        }
    }
}
