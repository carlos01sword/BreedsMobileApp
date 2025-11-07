import Testing
import ComposableArchitecture
@testable import Breeds

@Suite("Detail Feature - Favorites")
@MainActor
struct DetailFeatureTests {
    
    @Test func favoriteButtonTogglesState() async {
        let store = TestStore(
            initialState: DetailFeature.State( breed: MockData.breed1),
            reducer: { DetailFeature() }
        )
        store.exhaustivity = .off(showSkippedAssertions: false)

        // Toggle button to add to favorites
        #expect(!store.state.isFavorite)
        await store.send(.favoriteButtonTapped)
        #expect(store.state.isFavorite)

        // Toggle button to remove from favorites
        await store.send(.favoriteButtonTapped)
        #expect(!store.state.isFavorite)
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

        detailStore.exhaustivity = .off(showSkippedAssertions: false)

        // No favorites in any feature
        #expect(breedListStore.state.favoriteBreeds.isEmpty)
        #expect(favoriteStore.state.favoriteBreeds.isEmpty)
        #expect(!detailStore.state.isFavorite)

        await detailStore.send(.favoriteButtonTapped)

        // All features reflect the change
        #expect(detailStore.state.isFavorite)
        #expect(breedListStore.state.favoriteBreeds.contains(where: { $0.id == breed.id }))
        #expect(favoriteStore.state.favoriteBreeds.contains(where: { $0.id == breed.id }))

        await detailStore.send(.favoriteButtonTapped)

        // All features reflect the removal
        #expect(!detailStore.state.isFavorite)
        #expect(breedListStore.state.favoriteBreeds.isEmpty)
        #expect(favoriteStore.state.favoriteBreeds.isEmpty)
    }
}
