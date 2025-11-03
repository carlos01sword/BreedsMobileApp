import ComposableArchitecture
import Foundation

@Reducer
struct FavoriteFeature {

    @ObservableState
    struct State: Equatable {
        var allBreeds: IdentifiedArrayOf<Breed> = []
        var favorites: IdentifiedArrayOf<Breed> {
            allBreeds.filter (\.isFavorite)
        }
    }

    enum Action: Equatable {
        case breedFavoriteToggled(id: Breed.ID)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .breedFavoriteToggled(let id):
                state.allBreeds[id: id]?.isFavorite.toggle()
                return .none
            }
        }
    }
}
