import ComposableArchitecture
import SwiftUI
internal import Combine

@Reducer
struct FavoriteReducer {

    @ObservableState
    struct State: Equatable {
        var breeds: IdentifiedArrayOf<DetailReducer.State> = []
        var detail: DetailReducer.State?

        @ObservationStateIgnored
        @Shared(.favoriteBreeds) var favoriteBreeds

        init(favoriteBreeds: Shared<IdentifiedArrayOf<Breed>> = Shared(.favoriteBreeds)) {
            self._favoriteBreeds = favoriteBreeds
            self.breeds = IdentifiedArray(
                uniqueElements: self.favoriteBreeds.map { DetailReducer.State(breed: $0) }
            )
        }
    }

    enum Action: Equatable {
        case onAppear
        case breedTapped(Breed)
        case dismissDetail
        case favoritesChanged(IdentifiedArrayOf<Breed>)
        case breeds(IdentifiedAction<Breed.ID, DetailReducer.Action>)
        case detail(DetailReducer.Action)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            case .onAppear:
                return .run { [sharedBreeds = state.$favoriteBreeds] send in
                    for await favorites in sharedBreeds.publisher.values {
                        await send(.favoritesChanged(favorites))
                    }
                }

            case .breedTapped(let breed):
                if let existingState = state.breeds[id: breed.id] {
                    state.detail = existingState
                }
                return .none

            case .dismissDetail:
                state.detail = nil
                return .none

            case .favoritesChanged(let favorites):
                state.breeds = IdentifiedArray(
                    uniqueElements: favorites.map { breed in
                        state.breeds[id: breed.id] ?? DetailReducer.State(breed: breed)
                    }
                )

                if let detailBreed = state.detail?.breed,
                   !favorites.contains(where: { $0.id == detailBreed.id }) {
                    state.detail = nil
                }
                return .none

            case .detail, .breeds:
                return .none
            }
        }
        .forEach(\.breeds, action: \.breeds) { DetailReducer() }
        .ifLet(\.detail, action: \.detail) { DetailReducer() }
    }
}
