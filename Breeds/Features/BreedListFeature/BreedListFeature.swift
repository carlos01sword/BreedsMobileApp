import SwiftUI
import ComposableArchitecture

@Reducer
struct BreedListFeature {
    
    @ObservableState
    struct State: Equatable {
        @ObservationStateIgnored
        @Shared(.breeds) var breeds
        
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
                state.$breeds.withLock { $0 = IdentifiedArray(uniqueElements: breeds) }
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
                state.$breeds.withLock { $0[id: id]?.isFavorite.toggle() }
                return .none
            }
        }
    }
}
