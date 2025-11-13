import ComposableArchitecture
import SwiftUI

@Reducer
struct BreedCellReducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        let breed: Breed
        var isFavorite: Bool { favoriteBreeds.contains(where: { $0.id == breed.id }) }
        var image: UIImage?
        var isLoadingImage = false

        nonisolated var id: String { breed.id }

        @ObservationStateIgnored
        @Shared(.favoriteBreeds) var favoriteBreeds

        init(breed: Breed, favoriteBreeds: Shared<IdentifiedArrayOf<Breed>> = Shared(.favoriteBreeds)) {
            self._favoriteBreeds = favoriteBreeds
            self.breed = breed
        }
    }

    enum Action: Equatable {
        case favoriteButtonTapped
        case fetchImage
        case imageResponse(TaskResult<UIImage>)
    }

    @Dependency(\.imageClient) var imageClient

    var body: some Reducer<State,Action>{
        Reduce {state,action in
            switch action {
            case .favoriteButtonTapped:
                state.$favoriteBreeds.withLock { favorites in
                    if state.isFavorite {
                        _ = favorites.remove(id: state.breed.id)
                        return
                    }
                    _ = favorites.append(state.breed)
                }
                return .none

            case .fetchImage:
                guard !state.isLoadingImage, let referenceID = state.breed.referenceImageID else {
                    return .none
                }

                state.isLoadingImage = true
                return .run { send in
                    await send(
                        .imageResponse(
                            TaskResult { try await imageClient.fetchImage(referenceID) }
                        )
                    )
                }

            case .imageResponse(.success(let image)):
                state.image = image
                state.isLoadingImage = false
                return .none

            case .imageResponse(.failure):
                state.isLoadingImage = false
                return .none
            }
        }
    }
}
