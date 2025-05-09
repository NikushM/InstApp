import SwiftUI
import FirebaseFirestore

struct NewsFeedView: View {
    @Binding var isLoggedIn: Bool
    @State private var posts: [PostModel] = []
    @State private var isPresented = false
    
    var body: some View {
        NavigationView {
            List(posts) { post in
                PostCell(post: post)
            }
            .navigationTitle("News Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: ProfileView(isLoggedIn: $isLoggedIn)) {
                        Image(systemName: "person.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresented = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                fetchPosts()
            }
        }
        .sheet(isPresented: $isPresented) {
            PostUploadView(isPresented: $isPresented)
        }
    }
    
    /// ✅ Завантаження постів з Firestore
    private func fetchPosts() {
        let db = Firestore.firestore()
        db.collection("posts")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching posts: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                DispatchQueue.main.async {
                    self.posts = documents.compactMap { doc in
                        let data = doc.data()
                        return PostModel(id: doc.documentID, data: data)
                    }
                }
            }
    }
}

/// ✅ Кастомний вигляд для кожного посту
struct PostCell: View {
    var post: PostModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(url: URL(string: post.imageUrl)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                Text(post.userId)
                    .font(.headline)
            }
            
            AsyncImage(url: URL(string: post.imageUrl)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            
            Text(post.caption)
                .padding(.top, 5)
        }
        .padding()
    }
}

struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NewsFeedView(isLoggedIn: .constant(true))
    }
}
