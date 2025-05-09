import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

struct PostUploadView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var caption: String = ""
    @State private var selectedImage: UIImage?
    @State private var isUploading: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @Binding var isPresented: Bool  // Додаємо для закриття модального вікна

    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .cornerRadius(10)
                } else {
                    Text("Вибрати фото")
                        .foregroundColor(.blue)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                }
            }
            .onChange(of: selectedPhotoItem) { _, _ in
                loadSelectedImage()
            }

            TextField("🖋️Введіть опис...", text: $caption)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: uploadPost) {
                if isUploading {
                    ProgressView()
                } else {
                    Text("Опублікувати📷")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .disabled(selectedImage == nil || caption.isEmpty || isUploading)
        }
        .padding()
    }
    
    /// ✅ Завантажуємо зображення у Firebase Storage
    private func uploadPost() {
        guard let image = selectedImage else { return }
        isUploading = true
        
        FirebaseStorageManager.shared.uploadImage(image) { result in
            switch result {
            case .success(let imageUrl):
                savePostToFirestore(imageUrl: imageUrl)
            case .failure(let error):
                print("❌ Error uploading image: \(error.localizedDescription)")
                isUploading = false
            }
        }
    }
    
    /// ✅ Збереження поста у Firestore
    private func savePostToFirestore(imageUrl: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        userRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let username = data["username"] as? String,
                  let profileImageUrl = data["profileImageUrl"] as? String else {
                print("❌ Не вдалося отримати ім'я користувача або фото")
                isUploading = false
                return
            }

            let postId = UUID().uuidString
            let postData: [String: Any] = [
                "id": postId,
                "userId": userId,
                "username": username,
                "profileImageUrl": profileImageUrl,
                "imageUrl": imageUrl,
                "caption": caption,
                "createdAt": Date().timeIntervalSince1970
            ]

            db.collection("posts").document(postId).setData(postData) { error in
                isUploading = false
                if let error = error {
                    print("❌ Error saving post: \(error.localizedDescription)")
                } else {
                    print("✅ Post uploaded successfully!")
                    isPresented = false // Закриваємо модальне вікно
                }
            }
        }
    }

    /// ✅ Завантаження вибраного зображення
    private func loadSelectedImage() {
        guard let item = selectedPhotoItem else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedImage = uiImage
            }
        }
    }
}

#Preview {
    PostUploadView(isPresented: .constant(true))
}
