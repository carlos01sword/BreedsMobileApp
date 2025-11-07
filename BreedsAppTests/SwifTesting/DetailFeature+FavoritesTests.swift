import Testing
import ComposableArchitecture
@testable import Breeds

@Suite("Detail Feature - Favorites")
@MainActor
struct DetailFeatureTests {

    @Test func favoriteButtonTogglesState() async {
        let breed = MockData.breed1
        let sharedFavorites = Shared(value: IdentifiedArrayOf<Breed>())

        let store = TestStore(
            initialState: DetailFeature.State(
                breed: breed,
                favoriteBreeds: sharedFavorites
            ),
            reducer: { DetailFeature() }
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


    @Test func crossFeatureSync_ToggleFavoriteReflectsInBreedListAndFavoriteList() async {
        let breed = MockData.breed1
        let sharedFavorites = Shared(value: IdentifiedArrayOf<Breed>())

        let breedListStore = TestStore(
                initialState: BreedListFeature.State(
                    breeds: [breed],
                    favoriteBreeds: sharedFavorites
                ),
                reducer: { BreedListFeature() }
            )

        let detailStore = TestStore(
            initialState: DetailFeature.State(
                breed: breed,
                favoriteBreeds: sharedFavorites
            ),
            reducer: { DetailFeature() }
        )

        let favoriteStore = TestStore(
            initialState: FavoriteFeature.State(
                favoriteBreeds: sharedFavorites
            )
        ) {
            FavoriteFeature()
        }

        // No favorites in any feature
        #expect(breedListStore.state.favoriteBreeds.isEmpty)
        #expect(favoriteStore.state.favoriteBreeds.isEmpty)

        // Toggle favorite on from the Detail screen
        await detailStore.send(.favoriteButtonTapped) {
            $0.$favoriteBreeds.withLock { favorites in
                favorites.append(breed)
            }
        }

        // All features reflect the change
        #expect(!breedListStore.state.favoriteBreeds.isEmpty)
        #expect(!favoriteStore.state.favoriteBreeds.isEmpty)

        // Toggle favorite off from the Detail screen
        await detailStore.send(.favoriteButtonTapped) {
            $0.$favoriteBreeds.withLock { favorites in
                _ = favorites.remove(id: breed.id)
            }
        }

        // All features reflect the removal
        #expect(breedListStore.state.favoriteBreeds.isEmpty)
        #expect(favoriteStore.state.favoriteBreeds.isEmpty)
    }

    @Test func togglingBreed_DoesNotAffectOthers() async throws {
        let breed1 = MockData.breed1
        let breed2 = MockData.breed2
        let sharedFavorites = Shared(value: IdentifiedArrayOf<Breed>())

        let store1 = TestStore(
            initialState: DetailFeature.State(breed: breed1, favoriteBreeds: sharedFavorites),
            reducer: { DetailFeature() }
        )
        let store2 = TestStore(
            initialState: DetailFeature.State(breed: breed2, favoriteBreeds: sharedFavorites),
            reducer: { DetailFeature() }
        )

        // Toggle favorite for the first breed
        await store1.send(.favoriteButtonTapped) {
            $0.$favoriteBreeds.withLock { favorites in
                favorites.append(breed1)
            }
        }

        // Confirm no state change for the second breed
        #expect(!store2.state.isFavorite)
    }
}
