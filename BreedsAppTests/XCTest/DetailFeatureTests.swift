import XCTest
import ComposableArchitecture
@testable import Breeds

@MainActor
final class DetailFeatureTests: XCTestCase {
    func test_favoriteButtonTogglesState() async {
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
}
