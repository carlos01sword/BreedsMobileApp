import SwiftUI
import ComposableArchitecture

@main
struct BreedsApp: App {
    private let store = Store(
        initialState: BreedListFeature.State(),
        reducer: { BreedListFeature() }
    )
    
    private let favoriteStore = Store(
        initialState: FavoriteFeature.State(),
        reducer: { FavoriteFeature() }
    )

    var body: some Scene {
        WindowGroup {
            BreedTabView(store: store, favoriteStore: favoriteStore)
        }
    }
}

