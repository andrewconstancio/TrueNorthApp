import UIKit
import FirebaseStorage

struct ImageUploader {
    
    static func uploadImage(image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw NSError(domain: "ImageUploader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image to JPEG"])
        }
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_image/\(filename)")
        
        // Upload image data
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            ref.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
        
        // Get download URL
        let downloadURL: String = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            ref.downloadURL { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let urlString = url?.absoluteString {
                    continuation.resume(returning: urlString)
                } else {
                    continuation.resume(throwing: NSError(domain: "ImageUploader", code: -2, userInfo: [NSLocalizedDescriptionKey: "Download URL not found"]))
                }
            }
        }
        
        return downloadURL
    }
}


