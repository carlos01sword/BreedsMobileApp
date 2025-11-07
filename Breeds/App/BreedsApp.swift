import SwiftUI
import ComposableArchitecture

@main
struct BreedsApp: App {
    private let store = Store(
        initialState: BreedListReducer.State(),
        reducer: { BreedListReducer() }
    )
    
    private let favoriteStore = Store(
        initialState: FavoriteReducer.State(),
        reducer: { FavoriteReducer() }
    )

    var body: some Scene {
        WindowGroup {
            BreedTabView(store: store, favoriteStore: favoriteStore)
        }
    }
}

