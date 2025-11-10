import ComposableArchitecture
import SwiftUI

struct ImageCardView: View {
    let breed: Breed

    @Dependency(\.imageClient) var imageClient
    @State private var uiImage: UIImage?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
            } else {
                Image(systemName: "pawprint.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray.opacity(0.6))
                }
        }
        .task {
            do {
                uiImage = try await imageClient.fetchImage(breed.referenceImageID ?? "")
            } catch {
                print("Failed to fetch image:", error)
            }
            isLoading = false
        }
    }
}

#if DEBUG
    #Preview {
        ImageCardView(breed: MockData.sampleBreed)
            .frame(width: 300, height: 300)
    }
#endif
