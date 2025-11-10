import ComposableArchitecture
import SwiftUI

struct FavoriteView: View {
    @Bindable var store: StoreOf<FavoriteReducer>

    var body: some View {
        NavigationStack {
            if store.favorites.isEmpty{
                FavoriteEmptyStateView()
            }
            else {
                ScrollView {
                    ForEach(store.favorites) { breed in
                        Button {
                            store.send(.breedTapped(breed))
                        } label: {
                            BreedRowView(
                                breed: breed,
                                isFavorite: true,
                                onFavoriteTapped: { store.send(.breedFavoriteToggled(id: breed.id)) },
                                fetchImage: { store.send(.fetchImage(id: breed.id)) },
                                image: breed.image,
                                isLoading: breed.isLoadingImage
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
                        get: { store.detail?.breed },
                        set: { _ in store.send(.dismissDetail) }
                    )
                ) { _ in
                    if let detailStore = store.scope(state: \.detail, action: \.detail) {
                        DetailView( store: detailStore )
                    }
                }
            }
        }
    }
}


#if DEBUG
    #Preview {
        FavoriteView(
            store: Store(initialState: FavoriteReducer.State()) {
                FavoriteReducer()
            }
        )
    }
#endif
