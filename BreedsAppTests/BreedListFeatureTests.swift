import XCTest
import ComposableArchitecture
@testable import Breeds

@MainActor
final class BreedListFeatureTests: XCTestCase {

    func testFetchBreedsSuccess() async {
        let mockBreeds = [
            Breed(id: "1", name: "Abyssinian", origin: "", temperament: "", description: "", lifeSpan: "", referenceImageID: nil, isFavorite: false),
            Breed(id: "2", name: "Siamese", origin: "", temperament: "", description: "", lifeSpan: "", referenceImageID: nil, isFavorite: false)
        ]
        
        let store = TestStore(initialState: BreedListFeature.State()) {
            BreedListFeature()
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
