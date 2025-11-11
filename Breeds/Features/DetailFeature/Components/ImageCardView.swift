import ComposableArchitecture
import SwiftUI

struct ImageCardView: View {
    let image: UIImage?
    let isLoading: Bool
    let fetchImage: () -> Void

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
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
        .onAppear {
            if image == nil && !isLoading {
                fetchImage()
            }
        }
    }
}

#if DEBUG
#Preview {
    ImageCardView(
        image: nil,
        isLoading: false,
        fetchImage: {}
    )
    .frame(width: 300, height: 300)
    .cardImageStyle()
}
#endif
