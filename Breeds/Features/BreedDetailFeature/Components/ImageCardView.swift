import ComposableArchitecture
import SwiftUI

struct ImageCardView: View {
    let breed: Breed

    @Dependency(\.imageClient) var imageClient
    @State private var uiImage: UIImage?

    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
                    .task {
                        do {
                            uiImage = try await imageClient.fetchImage(
                                breed.referenceImageID ?? ""
                            )
                        } catch {
                            print("Failed to fetch image:", error)
                        }
                    }
            }
        }
    }
}

#if DEBUG
    #Preview {
        ImageCardView(breed: MockData.sampleBreed)
            .frame(width: 300, height: 300)
    }
#endif
