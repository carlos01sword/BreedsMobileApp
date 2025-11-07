import XCTest
import ComposableArchitecture
@testable import Breeds

@MainActor
final class DetailTests: XCTestCase {
    
    func testFavoriteButtonTogglesState() async {
        let sharedFavorites = Shared(value: IdentifiedArrayOf<Breed>())
        let breed = MockData.breed1
        let store = TestStore(
            initialState: DetailFeature.State(
                breed: MockData.breed1,
                favoriteBreeds: sharedFavorites
            ),
            reducer: { DetailFeature() }
        )

        await store.send(.favoriteButtonTapped) {
            $0.$favoriteBreeds.withLock { favorites in
                favorites.append(breed)
            }
        }
        await store.send(.favoriteButtonTapped) {
            $0.$favoriteBreeds.withLock { favorites in
                _ = favorites.remove(id: breed.id)
            }
        }
    }

    func testCrossFeatureSync_ToggleFavoriteReflectsInBreedListAndFavoriteList() async {
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
        XCTAssertTrue(breedListStore.state.favoriteBreeds.isEmpty)
        XCTAssertTrue(favoriteStore.state.favoriteBreeds.isEmpty)

        // Toggle favorite on from the Detail screen
        await detailStore.send(.favoriteButtonTapped) {
            $0.$favoriteBreeds.withLock { favorites in
                favorites.append(breed)
            }
        }

        // All features reflect the change
        XCTAssertTrue(breedListStore.state.favoriteBreeds.contains(where: { $0.id == breed.id }))
        XCTAssertTrue(favoriteStore.state.favoriteBreeds.contains(where: { $0.id == breed.id }))

        // Toggle favorite off from the Detail screen
        await detailStore.send(.favoriteButtonTapped) {
            $0.$favoriteBreeds.withLock { favorites in
                _ = favorites.remove(id: breed.id)
            }
        }

        // All features reflect the removal
        XCTAssertTrue(breedListStore.state.favoriteBreeds.isEmpty)
        XCTAssertTrue(favoriteStore.state.favoriteBreeds.isEmpty)
    }

    func testTogglingBreed_DoesNotAffectOthers () async throws {
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
        XCTAssertFalse(store2.state.isFavorite)
    }
}
