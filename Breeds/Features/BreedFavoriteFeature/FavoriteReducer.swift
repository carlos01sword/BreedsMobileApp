import ComposableArchitecture
import SwiftUI

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
        case fetchImage(id: Breed.ID)
        case imageResponse(id: Breed.ID, TaskResult<UIImage>)
    }

    @Dependency(\.imageClient) var imageClient

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

            case .detail(let detailAction):
                switch detailAction {
                case .favoriteButtonTapped:
                    if state.favoriteBreeds.isEmpty { state.detail = nil }
                    return .none
                case .fetchImage:
                    return .none
                case .imageResponse:
                    return .none
                }

            case .fetchImage(let id):
                guard let index = state.favoriteBreeds.firstIndex(where: { $0.id == id }) else {
                    return .none
                }
                let breed = state.favoriteBreeds[index]
                guard breed.image == nil, !breed.isLoadingImage else {
                    return .none
                }
                guard let referenceID = breed.referenceImageID else {
                    return .none
                }
                state.$favoriteBreeds.withLock { favorites in
                    favorites[index].isLoadingImage = true
                }
                return .run { [referenceID] send in
                    await send(.imageResponse(id: id, TaskResult {
                        try await imageClient.fetchImage(referenceID)
                    }))
                }

            case .imageResponse(let id, let result):
                guard let index = state.favoriteBreeds.firstIndex(where: { $0.id == id }) else { return .none }
                state.$favoriteBreeds.withLock { favorites in
                    favorites[index].isLoadingImage = false
                    switch result {
                    case .success(let image): favorites[index].image = image
                    case .failure: favorites[index].image = nil
                    }
                }
                return .none
            }
        }
        .ifLet(\.detail, action: \.detail){
            DetailReducer()
        }
    }
}
