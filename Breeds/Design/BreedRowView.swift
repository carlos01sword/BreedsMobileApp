import SwiftUI

struct breedRowView: View {
    
    let onFavoriteTapped: Bool = true
    var breed: Breed
    
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
            // TODO: Implement favorites logic
            Image(systemName: /*breed.isFavorite ? */ "star.fill" /*: "star"*/)
                .foregroundColor(.yellow)
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
#Preview {
    breedRowView(breed: Breed(id: "01", name: "Cat meow meow", origin: "", temperament: "", description: "", life_span: "", reference_image_id: "", isFavorite: false))
        .padding()
}
#endif
