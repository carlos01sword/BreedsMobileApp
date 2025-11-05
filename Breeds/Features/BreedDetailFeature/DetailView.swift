import ComposableArchitecture
import SwiftUI

struct DetailView: View {

    var breed: Breed
    var isFavorite: Bool

    //@Bindable var store: StoreOf<BreedListFeature>

    var body: some View{
        NavigationStack{
            ScrollView {
                VStack(spacing: ConstantsUI.largeVerticalSpacing) {

                    Text(breed.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    ImageCardView(breed: breed)

                    InfoCardView(breed: breed)

                    Button(action: {
                        print("TODO: SEND ACTION VIA STORE")
                    }) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundColor(.yellow)
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
        breed: MockData.sampleBreed,
        isFavorite: isFavorite,
    )
}
#endif
