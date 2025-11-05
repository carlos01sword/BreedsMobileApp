import ComposableArchitecture
import Foundation

@Reducer
struct FavoriteFeature {

    @ObservableState
    struct State: Equatable {
        @Shared(.favoriteBreeds) var favoriteBreeds
        
        var favorites: IdentifiedArrayOf<Breed> {
            favoriteBreeds
        }
        var selectedBreed: Breed?

        init(favoriteBreeds: Shared<IdentifiedArrayOf<Breed>> = Shared(.favoriteBreeds)) {
                self._favoriteBreeds = favoriteBreeds
            }
    }

    enum Action: Equatable {
        case breedFavoriteToggled(id: Breed.ID)
        case breedSelectTapped(Breed)
        case dismissDetail
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .breedFavoriteToggled(let id):
                _ = state.$favoriteBreeds.withLock { $0.remove(id: id) }
                return .none

            case .breedSelectTapped(let breed):
                state.selectedBreed = breed
                return .none
                
            case .dismissDetail:
                state.selectedBreed = nil
                return .none
            }
        }
    }
}
