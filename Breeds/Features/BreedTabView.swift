import ComposableArchitecture
import SwiftUI

struct BreedTabView: View {
    var store: StoreOf<BreedListFeature>
    var favoriteStore: StoreOf<FavoriteFeature>
        

    var body: some View {
        TabView {
            BreedListView(store: store)
                .tabItem {
                    Label("All", systemImage: "pawprint.fill")
                }

            FavoriteView(store: favoriteStore)
            .tabItem {
                Label("Favorites", systemImage: "star.fill")
            }
        }
    }
}

#if DEBUG
    #Preview {
        BreedTabView(
            store: Store(
                initialState: BreedListFeature.State(),
                reducer: { BreedListFeature() }
            ),
            favoriteStore: Store(
                initialState: FavoriteFeature.State(),
                reducer: { FavoriteFeature() }
            )
        )
    }
#endif
