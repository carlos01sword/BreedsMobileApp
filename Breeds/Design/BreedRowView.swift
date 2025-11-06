import ComposableArchitecture
import SwiftUI

struct BreedRowView: View {

    var breed: Breed
    var isFavorite: Bool
    var onFavoriteTapped: () -> Void

    var body: some View {
        HStack(spacing: .rowSpacing) {
            Image(systemName: "pawprint.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(breed.name)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()
            Button(action: onFavoriteTapped){
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: .rowCornerRadius)
                .fill(Color(.systemBackground))
                .shadow()
        )
    }
}

private extension CGFloat {
    static let rowSpacing: Self = 16
    static let rowCornerRadius: Self = 16
}

#if DEBUG
#Preview("Interactive Favorite Toggle") {
  @Previewable @State var isFavorite: Bool = false
    let sampleBreed = Breed(
        id: "01",
        name: "Cat meow meow",
        origin: "",
        temperament: "",
        description: "",
        lifeSpan: "",
        referenceImageID: nil,
    )

    BreedRowView(
        breed: sampleBreed,
        isFavorite: isFavorite,
        onFavoriteTapped: {
            isFavorite.toggle()
        }
    )
    .padding()
}
#endif
