import ComposableArchitecture
import SwiftUI

struct BreedTabView: View {
    var store: StoreOf<BreedListFeature>

    var body: some View {
        TabView {
            BreedListView(store: store)
                .tabItem {
                    Label("All", systemImage: "pawprint.fill")
                }

            FavoriteView(
                store: store.scope(state: \.favoriteState, action: \.favoriteAction)
            )
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
            )
        )
    }
#endif
