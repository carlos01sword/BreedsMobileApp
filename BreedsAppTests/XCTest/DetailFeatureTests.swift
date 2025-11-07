import XCTest
import ComposableArchitecture
@testable import Breeds

@MainActor
final class DetailTests: XCTestCase {
    
    func testFavoriteButtonTogglesState() async {
        let store = TestStore(
            initialState: DetailFeature.State( breed: MockData.breed1),
            reducer: { DetailFeature() }
        )
        store.exhaustivity = .off(showSkippedAssertions: false)

        // Toggle button to add to favorites
        XCTAssertFalse(store.state.isFavorite)
        await store.send(.favoriteButtonTapped)
        XCTAssertTrue(store.state.isFavorite)

        // Toggle button to remove from favorites
        await store.send(.favoriteButtonTapped)
        XCTAssertFalse(store.state.isFavorite)
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

        detailStore.exhaustivity = .off(showSkippedAssertions: false)

        // No favorites in any feature
        XCTAssertTrue(breedListStore.state.favoriteBreeds.isEmpty)
        XCTAssertTrue(favoriteStore.state.favoriteBreeds.isEmpty)
        XCTAssertFalse(detailStore.state.isFavorite)

        await detailStore.send(.favoriteButtonTapped)

        // All features reflect the change
        XCTAssertTrue(detailStore.state.isFavorite)
        XCTAssertTrue(breedListStore.state.favoriteBreeds.contains(where: { $0.id == breed.id }))
        XCTAssertTrue(favoriteStore.state.favoriteBreeds.contains(where: { $0.id == breed.id }))

        await detailStore.send(.favoriteButtonTapped)

        // All features reflect the removal
        XCTAssertFalse(detailStore.state.isFavorite)
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
        store1.exhaustivity = .off(showSkippedAssertions: false)
        store2.exhaustivity = .off(showSkippedAssertions: false)

        await store1.send(.favoriteButtonTapped)
        XCTAssertTrue(store1.state.isFavorite)
        XCTAssertFalse(store2.state.isFavorite)
    }
}
