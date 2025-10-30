import ComposableArchitecture
import SwiftUI

@Reducer
struct BreedListFeature {

    struct State: Equatable {
        var breeds: IdentifiedArrayOf<Breed> = []
        var isLoading: Bool = false
        var errorMessage: String?
    }

    enum Action: Equatable {
        case fetchBreeds
        case breedsResponse(TaskResult<[Breed]>)
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
            }
        }
    }
}

struct BreedListView: View {
    let store: StoreOf<BreedListFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    if viewStore.isLoading {
                        ProgressView()
                    }
                    if let errorMessage = viewStore.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    ScrollView {
                        ForEach(viewStore.breeds) { breed in
                            BreedRowView(breed: breed)
                        }
                        .contentShape(Rectangle())
                        .padding(.horizontal)
                        .padding(.vertical, ConstantsUI.defaultVerticalSpacing)
                    }
                }
                .navigationTitle("🐈 Cat Breeds")
                .onAppear {
                    viewStore.send(.fetchBreeds)
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
