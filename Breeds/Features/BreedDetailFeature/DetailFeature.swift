import ComposableArchitecture
import Foundation

@Reducer
struct DetailFeature {
    @ObservableState
    struct State: Equatable {
        let breed: Breed
        var isFavorite: Bool { favoriteBreeds.contains(where: { $0.id == breed.id }) }

        @ObservationStateIgnored
        @Shared(.favoriteBreeds) var favoriteBreeds

        init(breed: Breed, favoriteBreeds: Shared<IdentifiedArrayOf<Breed>> = Shared(.favoriteBreeds)) {
            self._favoriteBreeds = favoriteBreeds
            self.breed = breed
        }
    }

    enum Action {
        case favoriteButtonTapped
    }

    var body: some Reducer<State,Action>{
        Reduce {state,action in
            switch action {
            case .favoriteButtonTapped:
                    _ = state.$favoriteBreeds.withLock { favorites in
                        isFavorite ? favorites.remove(id: state.breed.id) : favorites.append(state.breed)
                        favorites.remove(id: state.breed.id)
                     }
                return .none
            }
        }
    }
}
