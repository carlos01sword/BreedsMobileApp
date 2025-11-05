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
                        Button {
                            store.send(.breedSelectTapped(breed))
                        } label: {
                            BreedRowView(
                                breed: breed,
                                isFavorite: true,
                                onFavoriteTapped: { store.send(.breedFavoriteToggled(id: breed.id)) }
                            )
                        }
                    }
                    .contentShape(Rectangle())
                    .padding(.horizontal)
                    .padding(.vertical, ConstantsUI.defaultVerticalSpacing)
                }
                .navigationTitle("⭐ Favorites")
                .navigationDestination(
                    item: Binding(
                        get: { store.selectedBreed },
                        set: { _ in store.send(.dismissDetail) }
                    )
                ) { breed in
                    DetailView(breed: breed)
                }
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
