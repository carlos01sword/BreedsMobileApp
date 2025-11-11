import SwiftUI
import ComposableArchitecture

@Reducer
struct BreedListReducer {

    @ObservableState
    struct State: Equatable {
        var breeds: IdentifiedArrayOf<DetailReducer.State> = []
        var isLoading: Bool = false
        var errorMessage: String?
        var detail: DetailReducer.State?
        var currentPage: Int = 0
        var canLoadMore: Bool = true

        @ObservationStateIgnored
        @Shared(.favoriteBreeds) var favoriteBreeds

        init(
            breeds: IdentifiedArrayOf<DetailReducer.State> = [],
            favoriteBreeds: Shared<IdentifiedArrayOf<Breed>> = Shared(.favoriteBreeds)
        ) {
            self.breeds = breeds
            self._favoriteBreeds = favoriteBreeds
        }
    }

    enum Action: Equatable {
        case fetchBreeds
        case loadMore
        case breedsResponse(TaskResult<[Breed]>)
        case breedTapped(Breed)
        case dismissDetail
        case breeds(IdentifiedAction<Breed.ID, DetailReducer.Action>)
        case detail(DetailReducer.Action)
    }


    @Dependency(\.breedsClient) var breedsClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            case .fetchBreeds:
                state.isLoading = true
                state.errorMessage = nil
                state.currentPage = 0
                return .run { send in
                    do {
                        let breeds = try await breedsClient.fetchBreeds(0, 10)
                        await send(.breedsResponse(.success(breeds)))
                    } catch {
                        await send(.breedsResponse(.failure(error)))
                    }
                }

            case .loadMore:
                guard !state.isLoading, state.canLoadMore else { return .none }
                state.isLoading = true
                let nextPage = state.currentPage + 1
                return .run { send in
                    do {
                        let breeds = try await breedsClient.fetchBreeds(nextPage, 10)
                        await send(.breedsResponse(.success(breeds)))
                    } catch {
                        await send(.breedsResponse(.failure(error)))
                    }
                }

            case .breedsResponse(.success(let breeds)):
                state.isLoading = false
                if breeds.isEmpty {
                    state.canLoadMore = false
                    return .none
                }

                if state.currentPage == 0 {
                    state.breeds = IdentifiedArray(
                        uniqueElements: breeds.map { DetailReducer.State(breed: $0) }
                    )
                } else {
                    let newItems = breeds.map { DetailReducer.State(breed: $0) }
                    state.breeds.append(contentsOf: newItems)
                }

                state.currentPage += 1
                return .none

            case .breedsResponse(.failure(let error)):
                state.isLoading = false
                state.errorMessage = (error as? NetworkError)?.description ?? error.localizedDescription
                return .none

            case .breedTapped(let breed):
                state.detail = state.breeds[id: breed.id] ?? DetailReducer.State(breed: breed)
                return .none

            case .dismissDetail:
                state.detail = nil
                return .none

            case .breeds, .detail:
                return .none
            }
        }
        .forEach(\.breeds, action: \.breeds) { DetailReducer() }
        .ifLet(\.detail, action: \.detail) { DetailReducer() }
    }
}
