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
    }

    enum Action: Equatable {
        case breedFavoriteToggled(id: Breed.ID)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .breedFavoriteToggled(let id):
                _ = state.$favoriteBreeds.withLock { $0.remove(id: id) }
                return .none
            }
        }
    }
}
