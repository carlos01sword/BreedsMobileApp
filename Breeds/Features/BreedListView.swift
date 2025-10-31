import ComposableArchitecture
import SwiftUI

@Reducer
struct BreedListFeature {
    
    @ObservableState
    struct State: Equatable {
        var breeds: IdentifiedArrayOf<Breed> = []
        var isLoading: Bool = false
        var errorMessage: String?
    }

    enum Action: Equatable {
        case fetchBreeds
        case breedsResponse(TaskResult<[Breed]>)
        case breedFavoriteToggled(id: Breed.ID)
    }

    @Dependency(\.breedsClient) var breedsClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchBreeds:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let breeds = try await breedsClient.fetchBreeds()
                        await send(.breedsResponse(.success(breeds)))
                    } catch {
                        await send(.breedsResponse(.failure(error)))
                    }

                }
            case .breedsResponse(.success(let breeds)):
                state.isLoading = false
                state.breeds = IdentifiedArray(uniqueElements: breeds)
                return .none
                
            case .breedsResponse(.failure(let error)):
                state.isLoading = false
                if let networkError = error as? NetworkError {
                    state.errorMessage = networkError.description
                } else {
                    state.errorMessage = error.localizedDescription
                }
                return .none
                
            case .breedFavoriteToggled(let id):
                state.breeds[id: id]?.isFavorite.toggle()
                return .none
            }
        }
    }
}

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
                store.send(.fetchBreeds)
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
