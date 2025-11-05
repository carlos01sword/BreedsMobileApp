import ComposableArchitecture
import SwiftUI

struct BreedDetailCardView: View {
    let breed: Breed

    var body: some View {
        ScrollView {
            VStack(spacing: ConstantsUI.largeVerticalSpacing) {

                Text(breed.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                ImageCard(breed: breed)

                VStack(alignment: .leading, spacing: ConstantsUI.largeVerticalSpacing) {

                    Text("Curious Facts!")
                        .font(.largeTitle)
                        .fontWeight(.semibold)

                    InfoRow(label: "Origin", value: breed.origin)
                    InfoRow(
                        label: "Life Span",
                        value: "\(breed.lifeSpan) years"
                    )
                    InfoRow(label: "Temperament", value: breed.temperament)
                    InfoRow(label: "Description", value: breed.description)

                }
                .padding(.horizontal, ConstantsUI.defaultPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, ConstantsUI.defaultPadding)
        }
    }
}

struct ImageCard: View {
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

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: ConstantsUI.extraSmallSpacing) {
            Text(label)
                .font(.headline)
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#if DEBUG
    #Preview {
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

        BreedDetailCardView(breed: sampleBreed)
    }
#endif
