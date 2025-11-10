import ComposableArchitecture
import SwiftUI

struct BreedListView: View {
    @Bindable var store: StoreOf<BreedListReducer>

    var body: some View {
        NavigationStack {
            ZStack {
                if store.isLoading {
                    ProgressView()
                }
                if let errorMessage = store.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                ScrollView {
                    ForEach(store.breeds) { breed in
                        Button {
                            store.send(.breedTapped(breed))
                        } label: {
                            BreedRowView(
                                breed: breed,
                                isFavorite: store.state.isFavorite(breed),
                                onFavoriteTapped: {
                                    store.send(.breedFavoriteToggled(id: breed.id))
                                },
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
            }
            .navigationTitle("🐈 Cat Breeds")
            .onAppear {
                if store.breeds.isEmpty {
                    store.send(.fetchBreeds)
                }
            }
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

#if DEBUG
#Preview {
        BreedListView(
            store: Store(initialState: BreedListReducer.State()) {
                BreedListReducer()
            }
        )
    }
#endif
