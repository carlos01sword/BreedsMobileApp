import SwiftUI
import ComposableArchitecture

@Reducer
struct BreedListFeature {
    
    @ObservableState
    struct State: Equatable {
        var breeds: IdentifiedArrayOf<Breed> = []
        var isLoading: Bool = false
        var errorMessage: String?
        
        var favoriteState: FavoriteFeature.State {
            get { FavoriteFeature.State(allBreeds: breeds) }
            set { breeds = newValue.allBreeds }
        }
    }

    enum Action: Equatable {
        case fetchBreeds
        case breedsResponse(TaskResult<[Breed]>)
        case breedFavoriteToggled(id: Breed.ID)
        case favoriteAction(FavoriteFeature.Action)
    }

    @Dependency(\.breedsClient) var breedsClient

    var body: some Reducer<State, Action> {
        
        Scope(state: \.favoriteState, action: \.favoriteAction){
            FavoriteFeature()
        }
        
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
                
            case .favoriteAction:
                return .none
            }
        }
    }
}
