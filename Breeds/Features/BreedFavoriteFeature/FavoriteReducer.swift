import ComposableArchitecture
import Foundation

@Reducer
struct FavoriteReducer {

    @ObservableState
    struct State: Equatable {
        var favorites: IdentifiedArrayOf<Breed> { favoriteBreeds }
        var detail: DetailReducer.State?

        @ObservationStateIgnored
        @Shared(.favoriteBreeds) var favoriteBreeds

        init(favoriteBreeds: Shared<IdentifiedArrayOf<Breed>> = Shared(.favoriteBreeds)) {
                self._favoriteBreeds = favoriteBreeds
            }
    }

    enum Action: Equatable {
        case breedFavoriteToggled(id: Breed.ID)
        case breedTapped(Breed)
        case dismissDetail
        case detail(DetailReducer.Action)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .breedFavoriteToggled(let id):
                _ = state.$favoriteBreeds.withLock { $0.remove(id: id) }
                return .none
                
            case .breedTapped(let breed):
                state.detail = DetailReducer.State(breed: breed)
                
                return .none
                
            case .dismissDetail:
                state.detail = nil
                return .none
                
            case .detail(.favoriteButtonTapped):
                if state.favoriteBreeds.isEmpty {
                    state.detail = nil
                }
                return .none
            }
        }
        .ifLet(\.detail, action: \.detail){
            DetailReducer()
        }
    }
}
