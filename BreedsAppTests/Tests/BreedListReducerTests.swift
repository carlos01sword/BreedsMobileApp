import Testing
import ComposableArchitecture
@testable import Breeds

@Suite("Breed List Feature – Favorites")
@MainActor
struct BreedListReducerTests {

    @Test
    func togglingBreedAddsToFavorites() async {
        let breed = MockData.breed1
        let store = TestStore(initialState: MockData.makeState(breeds: [breed])) {
            BreedListReducer()
        }
        await store.send(.breedFavoriteToggled(id: breed.id)) {
            $0.$favoriteBreeds.withLock { $0.append(breed) }
        }
    }
    
    @Test
    func togglingBreedRemovesFromFavorites() async {
        let favorited = MockData.favoritedBreed1
        let store = TestStore(
            initialState: MockData.makeState(breeds: [favorited], favorites: [favorited])
        ) {
            BreedListReducer()
        }
        
        await store.send(.breedFavoriteToggled(id: favorited.id)) {
            $0.$favoriteBreeds.withLock { $0.removeAll() }
        }
    }
    
    @Test
    func breedFavoriteToggled_IgnoresUnknownID() async {
        let breed = MockData.breed1
        let initialState = MockData.makeState(breeds: [breed])
        
        let store = TestStore(initialState: initialState) {
            BreedListReducer()
        }
        await store.send(.breedFavoriteToggled(id: "unknown-id"))
    }
}
