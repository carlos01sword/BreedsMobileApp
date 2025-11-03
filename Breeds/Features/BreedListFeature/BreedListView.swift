import ComposableArchitecture
import SwiftUI

struct BreedListView: View {
    @Bindable var store: StoreOf<BreedListFeature>
    
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
                        BreedRowView(
                            breed: breed,
                            onFavoriteTapped: {
                                store.send(.breedFavoriteToggled(id: breed.id))
                            }
                        )
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
        }
    }
}

#if DEBUG
#Preview {
        BreedListView(
            store: Store(initialState: BreedListFeature.State()) {
                BreedListFeature()
            }
        )
    }
#endif
