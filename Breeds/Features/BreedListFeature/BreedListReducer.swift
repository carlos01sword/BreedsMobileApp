import SwiftUI
import ComposableArchitecture

@Reducer
struct BreedListReducer {

    @ObservableState
    struct State: Equatable {
        var breeds: IdentifiedArrayOf<Breed> = []
        var isLoading: Bool = false
        var errorMessage: String?
        var detail: DetailReducer.State?

        @ObservationStateIgnored
        @Shared(.favoriteBreeds) var favoriteBreeds

        init(
            breeds: IdentifiedArrayOf<Breed> = [],
            favoriteBreeds: Shared<IdentifiedArrayOf<Breed>> = Shared(.favoriteBreeds)
        ) {
            self.breeds = breeds
            self._favoriteBreeds = favoriteBreeds
        }
    }

    enum Action: Equatable {
        case fetchBreeds
        case breedsResponse(TaskResult<[Breed]>)
        case breedFavoriteToggled(id: Breed.ID)
        case breedTapped(Breed)
        case dismissDetail
        case detail(DetailReducer.Action)
        case fetchImage(id: Breed.ID)
        case imageResponse(id: Breed.ID, TaskResult<UIImage>)
    }

    @Dependency(\.breedsClient) var breedsClient
    @Dependency(\.imageClient) var imageClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchBreeds:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let breeds = try await breedsClient.fetchBreeds()
                        await send(.breedsResponse(.success(breeds)))
                    } catch {
                        await send(.breedsResponse(.failure(error)))
                    }
                }
                
            case .breedsResponse(.success(let breeds)):
                state.isLoading = false
                state.breeds = IdentifiedArray(uniqueElements: breeds)
                return .none
                
            case .breedsResponse(.failure(let error)):
                state.isLoading = false
                if let networkError = error as? NetworkError {
                    state.errorMessage = networkError.description
                } else {
                    state.errorMessage = error.localizedDescription
                }
                return .none
                
            case .breedFavoriteToggled(let id):
                if state.favoriteBreeds.contains(where: { $0.id == id }) {
                    _ = state.$favoriteBreeds.withLock { favorites in
                        favorites.remove(id: id)
                    }
                } else if let breed = state.breeds[id: id] {
                    _ = state.$favoriteBreeds.withLock { favorites in
                        favorites.append(breed)
                    }
                }
                return .none

            case .breedTapped(let breed):
                state.detail = DetailReducer.State(breed:breed)
                return .none

            case .dismissDetail:
                state.detail = nil
                return .none

            case .detail:
                return .none

            case .fetchImage(let id):
                guard let index = state.breeds.firstIndex(where: { $0.id == id }) else {
                    return .none
                }
                guard state.breeds[index].image == nil, !state.breeds[index].isLoadingImage else {
                    return .none
                }
                guard let referenceImageID = state.breeds[index].referenceImageID else {
                    return .none
                }

                state.breeds[index].isLoadingImage = true

                return .run { [referenceImageID] send in
                    await send(.imageResponse(id: id, TaskResult {
                        try await imageClient.fetchImage(referenceImageID)
                    }))
                }

            case .imageResponse(let id, let result):
                guard let index = state.breeds.firstIndex(where: { $0.id == id }) else {
                    return .none
                }
                state.breeds[index].isLoadingImage = false

                switch result {
                case .success(let image):
                    state.breeds[index].image = image

                case .failure:
                    state.breeds[index].image = nil
                }
                return .none

            }
        }
        .ifLet(\.detail, action: \.detail) { DetailReducer() }
    }
}

extension BreedListReducer.State {
    func isFavorite(_ breed: Breed) -> Bool {
        favoriteBreeds.contains(where: { $0.id == breed.id })
    }
}
