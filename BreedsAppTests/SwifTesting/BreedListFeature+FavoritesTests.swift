import Testing
import ComposableArchitecture
@testable import Breeds

@Suite("Breed List Feature – Favorites")
@MainActor
struct BreedListFeatureFavoritesTests {
    
    @Test
    func togglingBreedAddsToFavorites() async {
        let breed = MockData.breed1
        let store = TestStore(initialState: MockData.makeState(breeds: [breed])) {
            BreedListFeature()
        }
        
        await store.send(.breedFavoriteToggled(id: breed.id)) {
            $0.$favoriteBreeds.withLock { $0.append(breed) }
        }
        
        #expect(store.state.favoriteBreeds.contains(where: { $0.id == breed.id }))
    }
    
    @Test
    func togglingBreedRemovesFromFavorites() async {
        let favorited = MockData.favoritedBreed1
        let store = TestStore(
            initialState: MockData.makeState(breeds: [favorited], favorites: [favorited])
        ) {
            BreedListFeature()
        }
        
        await store.send(.breedFavoriteToggled(id: favorited.id)) {
            $0.$favoriteBreeds.withLock { $0.removeAll() }
        }
        
        #expect(store.state.favoriteBreeds.isEmpty)
    }
    
    @Test
    func breedFavoriteToggled_IgnoresUnknownID() async {
        let breed = MockData.breed1
        let initialState = MockData.makeState(breeds: [breed])
        
        let store = TestStore(initialState: initialState) {
            BreedListFeature()
        }
        
        await store.send(.breedFavoriteToggled(id: "unknown-id"))
        #expect(store.state == initialState)
    }
    
    @Test
    func crossFeatureSync_RemovalReflectsInBreedList() async {
        let favorited = MockData.favoritedBreed1
        
        let sharedFavorites = Shared<IdentifiedArrayOf<Breed>>(
            value: IdentifiedArray(uniqueElements: [favorited])
        )
        
        let breedListStore = TestStore(
            initialState: BreedListFeature.State(
                breeds: [favorited],
                favoriteBreeds: sharedFavorites
            )
        ) {
            BreedListFeature()
        }
        
        let favoriteStore = TestStore(
            initialState: FavoriteFeature.State(
                favoriteBreeds: sharedFavorites
            )
        ) {
            FavoriteFeature()
        }
        
        await favoriteStore.send(.breedFavoriteToggled(id: favorited.id)) {
            $0.$favoriteBreeds.withLock { $0.removeAll() }
        }
        
        #expect(breedListStore.state.favoriteBreeds.isEmpty)
    }
}
