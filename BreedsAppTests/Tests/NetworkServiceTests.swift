import Testing
import ComposableArchitecture
@testable import Breeds

@Suite("Breed List Feature – Network Service")
@MainActor
struct NetworkServiceTests{

    @Test func fetchBreedsSuccess() async {
        let mockBreeds = [MockData.breed1, MockData.breed2]
        
        let store = TestStore(initialState: BreedListReducer.State()) {
            BreedListReducer()
        }
        
        store.dependencies.breedsClient.fetchBreeds = { mockBreeds }
        
        await store.send(.fetchBreeds) {
            $0.isLoading = true
            $0.errorMessage = nil
        }
        
        await store.receive(.breedsResponse(.success(mockBreeds))) {
            $0.isLoading = false
            $0.breeds = IdentifiedArray(uniqueElements: mockBreeds)
        }
    }
}
