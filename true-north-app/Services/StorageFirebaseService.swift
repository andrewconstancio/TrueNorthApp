import UIKit
import FirebaseStorage

struct StorageFirebaseService {
    
    static func uploadImage(image: UIImage) async throws -> String {
        // Try higher quality first, fallback to lower if needed
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageUploader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image to JPEG"])
        }
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_image/\(filename)")
        
        // Set metadata to ensure proper content type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload image data with metadata
        let uploadMetadata = try await ref.putDataAsync(imageData, metadata: metadata)
        
        // Verify upload was successful
        guard uploadMetadata.size == imageData.count else {
            throw NSError(domain: "ImageUploader", code: -3, userInfo: [NSLocalizedDescriptionKey: "Upload verification failed - size mismatch"])
        }
        
        // Get download URL
        let downloadURL = try await ref.downloadURL()
        
        return downloadURL.absoluteString
    }
}
