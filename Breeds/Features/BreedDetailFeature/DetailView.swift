import ComposableArchitecture
import SwiftUI

struct DetailView: View {

    var breed: Breed

    var body: some View{
        NavigationStack{
            BreedDetailCardView(breed: breed)
                .toolbar(.hidden, for: .tabBar)
        }
    }
}


#if DEBUG
#Preview{

    let sampleBreed = Breed(
        id: "01",
        name: "Cat meow meow",
        origin: "meow meow land",
        temperament: "very meow",
        description:
            "meow meows all around the world. Meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow",
        lifeSpan: "10-20",
        referenceImageID: "0XYvRd7oD",
    )

    DetailView(breed: sampleBreed)
}
#endif
