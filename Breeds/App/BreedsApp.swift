import SwiftUI
import ComposableArchitecture

@main
struct BreedsApp: App {
    private let store = Store(
        initialState: BreedListFeature.State(),
        reducer: { BreedListFeature() }
    )

    var body: some Scene {
        WindowGroup {
            BreedTabView(store: store)
        }
    }
}

