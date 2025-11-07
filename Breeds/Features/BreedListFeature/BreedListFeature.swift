import SwiftUI
import ComposableArchitecture

@Reducer
struct BreedListFeature {
    
    @ObservableState
    struct State: Equatable {
        var breeds: IdentifiedArrayOf<Breed> = []
        var isLoading: Bool = false
        var errorMessage: String?
        var detail: DetailFeature.State?

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
        case detail(DetailFeature.Action)
    }

    @Dependency(\.breedsClient) var breedsClient
 
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
                state.detail = DetailFeature.State(breed:breed)
                return .none

            case .dismissDetail:
                state.detail = nil
                return .none

            case .detail:
                return .none
            }
        }
        .ifLet(\.detail, action: \.detail) { DetailFeature() }
    }
}

extension BreedListFeature.State {
    func isFavorite(_ breed: Breed) -> Bool {
        favoriteBreeds.contains(where: { $0.id == breed.id })
    }
}
