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
                .foregroundColor(.gray.opacity(ConstantsUI.darkerOpacity))
                .scaledToFit()
                .frame(width: .imageRowFrameSize , height: .imageRowFrameSize)
                .clipShape(RoundedRectangle(cornerRadius: .imageRowCornerRadius))

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
    static let imageRowCornerRadius: Self = 8
    static let imageRowFrameSize: Self = 60
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
