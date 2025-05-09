import SwiftUI
import FirebaseFirestore

class PostViewModel: ObservableObject {
    @Published var posts: [PostModel] = []
    private var db = Firestore.firestore()

    init() {
        fetchPosts()
    }

    func fetchPosts() {
        db.collection("posts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching posts: \(error.localizedDescription)")
                    return
                }
                
                self.posts = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    return PostModel(id: document.documentID, data: data)
                } ?? []
            }
    }
}
