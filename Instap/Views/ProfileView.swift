import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    @State private var username: String = ""
    @State private var profileImage: UIImage?
    @State private var errorMessage: String?
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var navigateToNewsFeed = false
    
    var body: some View {
        VStack {
            // Фото профілю або дефолтний аватар
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            }
            
            // Кнопка зміни фото
            Button("📷 Змінити фото") {
                isImagePickerPresented = true
            }
            .padding()
            
            // Поле для імені користувача
            TextField("Введіть ім'я", text: $username, onCommit: saveUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Кнопка виходу
            Button("🚨 Вийти") {
                signOut()
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .cornerRadius(10)
            .padding(.horizontal, 20)
            
            Button("➡️ Продовжити") {
                navigateToNewsFeed = true
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal, 20)
            
            // Відображення помилки (якщо є)
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            fetchUserData()
            loadProfileImage()
        }
        .sheet(isPresented: $isImagePickerPresented, onDismiss: uploadProfileImage) {
            ImagePicker(selectedImage: $selectedImage) // Додано ImagePicker
        }
        .fullScreenCover(isPresented: $navigateToNewsFeed) {
            NewsFeedView(isLoggedIn: $isLoggedIn)
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            errorMessage = "Не вдалося вийти: \(error.localizedDescription)"
        }
    }
    
    /// Отримання даних користувача з Firestore
    private func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                errorMessage = "Помилка завантаження даних: \(error.localizedDescription)"
                return
            }
            username = snapshot?.data()?["username"] as? String ?? ""
        }
    }
    
    /// Автоматичне збереження імені користувача у Firestore
    private func saveUsername() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userRef = Firestore.firestore().collection("users").document(userId)
        userRef.setData(["username": username], merge: true) { error in
            if let error = error {
                errorMessage = "Помилка збереження імені: \(error.localizedDescription)"
            }
        }
    }
    
    private func loadProfileImage() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
        
        storageRef.getData(maxSize: Int64(__designTimeInteger("#1729_18", fallback: 5)) * Int64(__designTimeInteger("#1729_19", fallback: 1024)) * Int64(__designTimeInteger("#1729_20", fallback: 1024))) { data, error in
            if let error = error {
                print("Помилка завантаження фото: \(error.localizedDescription)")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                profileImage = image
            }
        }
    }
    
    private func uploadProfileImage() {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.4),
              let userId = Auth.auth().currentUser?.uid else { return }
        
        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                errorMessage = "Помилка збереження фото: \(error.localizedDescription)"
                return
            }
            loadProfileImage()
        }
    }
}

// ImagePicker для вибору фото з галереї
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

#Preview {
    ProfileView(isLoggedIn: .constant(true))
}
