import SwiftUI

struct ImageCardView: View {
    let breed: Breed

    private var url: URL? {
        guard let id = breed.referenceImageID, !id.isEmpty else { return nil }
        return URL(string: "https://cdn2.thecatapi.com/images/\(id).jpg")
    }

    var body: some View {

        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()

            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .cardImageStyle()

            case .failure:
                Image(systemName: "pawprint.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray.opacity(ConstantsUI.darkerOpacity))
                    .cardImageStyle()

            @unknown default:
                EmptyView()
            }
        }
    }
}

#if DEBUG
    #Preview {
        ImageCardView(breed: MockData.sampleBreed)
    }
#endif
