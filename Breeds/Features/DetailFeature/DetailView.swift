import ComposableArchitecture
import SwiftUI

struct DetailView: View {

    @Bindable var store: StoreOf<DetailReducer>

    var body: some View{
        NavigationStack{
            ScrollView {
                VStack(spacing: ConstantsUI.largeVerticalSpacing) {

                    Text(store.cell.breed.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    ImageCardView(
                        image: store.cell.image,
                        isLoading: store.cell.isLoadingImage,
                        fetchImage: { store.send(.cell(.fetchImage)) }
                    )
                    .cardImageStyle()

                    InfoCardView(breed: store.cell.breed)

                    Button {
                        store.send(.cell(.favoriteButtonTapped))
                    } label: {
                        Text(store.cell.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                            .favoritesButtonStyle()
                    }
                }
                .padding(.bottom, ConstantsUI.defaultPadding)
            }
            .toolbar(.hidden, for: .tabBar)
            .onAppear{
                store.send(.cell(.fetchImage))
            }
        }
    }
}


#if DEBUG
#Preview{
    DetailView(
        store: StoreOf<DetailReducer>(
            initialState: DetailReducer.State(
                cell: BreedCellReducer.State(breed: MockData.sampleBreed)
            ),
            reducer: { DetailReducer() }
        )
    )
}
#endif
