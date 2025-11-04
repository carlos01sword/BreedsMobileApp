import ComposableArchitecture
import SwiftUI

struct FavoriteView: View {
    @Bindable var store: StoreOf<FavoriteFeature>

    var body: some View {
        NavigationStack {
            if store.favorites.isEmpty{
                FavoriteEmptyStateView()
            }
            else {
                ScrollView {
                    ForEach(store.favorites) { breed in
                        BreedRowView(
                            breed: breed,
                            favoriteBreeds: store.favorites,
                            onFavoriteTapped: { store.send(.breedFavoriteToggled(id: breed.id)) }
                        )
                    }
                    .contentShape(Rectangle())
                    .padding(.horizontal)
                    .padding(.vertical, ConstantsUI.defaultVerticalSpacing)
                }
                .navigationTitle("⭐ Favorites")
            }
        }
    }
}

#if DEBUG
    #Preview {
        FavoriteView(
            store: Store(initialState: FavoriteFeature.State()) {
                FavoriteFeature()
            }
        )
    }
#endif
