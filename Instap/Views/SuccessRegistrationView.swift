import SwiftUI

struct SuccessRegistrationView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
            
            Text("Реєстрація успішна! 🎉")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Вітаємо в Instap! Тепер ви можете користуватися додатком.")
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                isLoggedIn = true
            }) {
                Text("Продовжити")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    SuccessRegistrationView(isLoggedIn: .constant(false))
}
