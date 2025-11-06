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
                if state.isFavorite {
                    _ = state.$favoriteBreeds.withLock { favorites in
                        favorites.remove(id: state.breed.id)
                    }
                } else {
                    _ = state.$favoriteBreeds.withLock { favorites in
                        favorites.append(state.breed)
                    }
                }
                return .none
            }
        }
    }
}
