import ComposableArchitecture
import SwiftUI

struct DetailView: View {

    @Bindable var store: StoreOf<DetailReducer>

    var body: some View{
        NavigationStack{
            ScrollView {
                VStack(spacing: ConstantsUI.largeVerticalSpacing) {

                    Text(store.breed.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    ImageCardView(breed: store.breed)

                    InfoCardView(breed: store.breed)

                    Button {
                        store.send(.favoriteButtonTapped)
                    } label: {
                        Text(store.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                            .favoritesButtonStyle()
                    }
                }
                .padding(.bottom, ConstantsUI.defaultPadding)
            }
            .toolbar(.hidden, for: .tabBar)
        }
    }
}


#if DEBUG
#Preview{
    @Previewable @State var isFavorite: Bool = false
    DetailView(
        store: StoreOf<DetailReducer>(
            initialState: DetailReducer.State(breed: MockData.sampleBreed),
            reducer: { DetailReducer() }
        )
    )
}
#endif
