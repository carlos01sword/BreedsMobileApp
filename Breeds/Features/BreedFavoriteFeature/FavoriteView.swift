import ComposableArchitecture
import SwiftUI

struct FavoriteView: View {
    @Bindable var store: StoreOf<FavoriteReducer>

    var body: some View {
        NavigationStack {
            if store.breeds.isEmpty {
                FavoriteEmptyStateView()
            }
            else {
                ScrollView {
                    ForEachStore(
                        self.store.scope(state: \.breeds, action: \.breeds)
                    ) { breedStore in
                        let breed = breedStore.state.breed
                        Button {
                            store.send(.breedTapped(breed))
                        } label: {
                            BreedRowView(store: breedStore)
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
        .onAppear {
            store.send(.onAppear)
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
