import SwiftUI
import ComposableArchitecture

@Reducer
struct BreedListFeature {
    
    @ObservableState
    struct State: Equatable {
        var breeds: IdentifiedArrayOf<Breed> = []
        @Shared(.favoriteBreeds) var favoriteBreeds
        var isLoading: Bool = false
        var errorMessage: String?
    }

    enum Action: Equatable {
        case fetchBreeds
        case breedsResponse(TaskResult<[Breed]>)
        case breedFavoriteToggled(id: Breed.ID)
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
                let favoriteIDs = Set(state.favoriteBreeds.map(\.id))
                let mergedBreeds = breeds.map {
                    var breed = $0
                    breed.isFavorite = favoriteIDs.contains(breed.id)
                    return breed
                }
                state.breeds = IdentifiedArray(uniqueElements: mergedBreeds)
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
                guard var breed = state.breeds[id: id] else { return .none }

                let isCurrentlyFavorite = state.favoriteBreeds.contains(where: { $0.id == id })
                let newIsFavorite = !isCurrentlyFavorite
                breed.isFavorite = newIsFavorite
                state.breeds[id: id] = breed

                state.$favoriteBreeds.withLock { favorites in
                    if newIsFavorite {
                        favorites.append(breed)
                    } else {
                        favorites.remove(id: id)
                    }
                }
                return .none
            }
        }
    }
}
