import SwiftUI

/// A view that asynchronously loads and caches images from a URL.
///
@MainActor
struct AsyncCachedImage<ImageView: View, PlaceholderView: View>: View {
    /// The URL of the image to load.
    var url: URL?
    
    /// View builder for the loaded image.
    @ViewBuilder var content: (Image) -> ImageView
    
    /// View builder for the placeholder.
    @ViewBuilder var placeholder: () -> PlaceholderView
    
    /// The downloaded or cached image.
    @State var image: UIImage? = nil
    
    /// Initializes a new async cached image view.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to load.
    ///   - content: View builder for the loaded image.
    ///   - placeholder: View builder for the placeholder.
    ///
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> ImageView,
        @ViewBuilder placeholder: @escaping () -> PlaceholderView
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
        
        /// Check cache on init to avoid showing placeholder.
        if let url = url,
           let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)),
           let cachedImage = UIImage(data: cachedResponse.data) {
            _image = State(initialValue: cachedImage)
        }
    }
    
    var body: some View {
        VStack {
            if let uiImage = image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            image = await downloadPhoto()
        }
    }
    
    /// Downloads the image from the URL or retrieves it from cache.
    ///
    /// - Returns: The downloaded or cached `UIImage`, or `nil` if download fails.
    ///
    private func downloadPhoto() async -> UIImage? {
        do {
            guard let url else {
                return nil
            }
            
            /// Check if the image is cached.
            if let cachedResponse = URLCache.shared.cachedResponse(for: .init(url: url)) {
                return UIImage(data: cachedResponse.data)
            } else {
                /// Show placeholder while downloading.
                image = nil
                
                let (data, response) = try await URLSession.shared.data(from: url)
                
                /// Save image data into the cache.
                URLCache.shared.storeCachedResponse(.init(response: response, data: data), for: .init(url: url))
                
                guard let image = UIImage(data: data) else {
                    return nil
                }
                
                return image
            }
        } catch {
            return nil
        }
    }
}

