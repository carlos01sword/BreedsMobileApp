import ComposableArchitecture
import Foundation

@Reducer
struct FavoriteFeature {

    @ObservableState
    struct State: Equatable {
        @ObservationStateIgnored
        @Shared(.breeds) var breeds
        
        var favorites: IdentifiedArrayOf<Breed> {
            breeds.filter (\.isFavorite)
        }
    }

    enum Action: Equatable {
        case breedFavoriteToggled(id: Breed.ID)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .breedFavoriteToggled(let id):
                state.$breeds.withLock { $0[id: id]?.isFavorite.toggle() }
                return .none
            }
        }
    }
}
