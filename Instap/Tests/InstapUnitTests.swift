import XCTest
import SwiftUICore
@testable import Instap
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage

final class AuthManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp() // Викликаємо метод setUp батьківського класу
        if FirebaseApp.app() == nil { // Перевіряємо, чи Firebase вже ініціалізовано
            FirebaseApp.configure() // Якщо ні, ініціалізуємо Firebase
        }
    }
    
    func testSignUpWithValidData() { // Тест для перевірки реєстрації з коректними даними
        let randomEmail = "testuser\(UUID().uuidString.prefix(5))@gmail.com" // Генеруємо унікальний email
        let expectation = self.expectation(description: "Sign up succeeds") // Створюємо очікування для асинхронного тесту
        
        AuthManager.shared.signUp(email: randomEmail, password: "password123", username: "testuser") { success, error in // Викликаємо метод реєстрації
            XCTAssertTrue(success, "Sign up should succeed with valid data") // Перевіряємо, чи реєстрація пройшла успішно
            XCTAssertNil(error, "Error should be nil on success") // Перевіряємо, чи немає помилок
            print("SignUp success:", success, "Error:", error?.localizedDescription ?? "No error") // Виводимо результат в консоль
            expectation.fulfill() // Виконуємо очікування
        }
        
        waitForExpectations(timeout: 10, handler: nil) // Очікуємо виконання очікування протягом 10 секунд
    }
    
    func testSignUpWithInvalidEmail() { // Тест для перевірки реєстрації з некоректним email
        let expectation = self.expectation(description: "Sign up fails with invalid email") // Створюємо очікування
        
        AuthManager.shared.signUp(email: "invalidemail", password: "password123", username: "testuser") { success, error in // Викликаємо метод реєстрації
            XCTAssertFalse(success, "Sign up should fail with invalid email") // Перевіряємо, чи реєстрація не пройшла
            XCTAssertNotNil(error, "Error should not be nil on failure") // Перевіряємо, чи є помилка
            print("SignUp with invalid email:", success, "Error:", error?.localizedDescription ?? "No error") // Виводимо результат
            expectation.fulfill() // Виконуємо очікування
        }
        
        waitForExpectations(timeout: 10, handler: nil) // Очікуємо виконання
    }
    
    func testSignInWithValidCredentials() { // Тест для перевірки входу з коректними даними
        let expectation = self.expectation(description: "Sign in succeeds") // Створюємо очікування
        
        AuthManager.shared.signIn(email: "testuser@gmail.com", password: "password123") { success, error in // Викликаємо метод входу
            XCTAssertTrue(success, "Sign in should succeed with valid credentials") // Перевіряємо, чи вхід пройшов успішно
            XCTAssertNil(error, "Error should be nil on success") // Перевіряємо, чи немає помилок
            print("SignIn success:", success, "Error:", error?.localizedDescription ?? "No error") // Виводимо результат
            expectation.fulfill() // Виконуємо очікування
        }
        
        waitForExpectations(timeout: 10, handler: nil) // Очікуємо виконання
    }
    
    func testSignInWithWrongPassword() { // Тест для перевірки входу з неправильним паролем
        let expectation = self.expectation(description: "Sign in fails with wrong password") // Створюємо очікування
        
        AuthManager.shared.signIn(email: "testuser@gmail.com", password: "wrongpassword") { success, error in // Викликаємо метод входу
            XCTAssertFalse(success, "Sign in should fail with wrong password") // Перевіряємо, чи вхід не пройшов
            XCTAssertNotNil(error, "Error should not be nil on failure") // Перевіряємо, чи є помилка
            print("SignIn with wrong password:", success, "Error:", error?.localizedDescription ?? "No error") // Виводимо результат
            expectation.fulfill() // Виконуємо очікування
        }
        
        waitForExpectations(timeout: 10, handler: nil) // Очікуємо виконання
    }
    
    func testFetchUserData() {
        let expectation = self.expectation(description: "Fetch user data succeeds")
        
        AuthManager.shared.signIn(email: "testuser@gmail.com", password: "password123") { success, error in
            XCTAssertTrue(success, "Sign in should succeed before fetching user data")
            XCTAssertNil(error, "Error should be nil on sign in")
            
            AuthManager.shared.fetchUserData { user, error in // Змінено на user та error
                if let user = user {
                    // Отримано дані користувача
                    XCTAssertNotNil(user.email, "Email should not be nil")
                    XCTAssertNotNil(user.username, "Username should not be nil")
                    XCTAssertNil(error, "Error should be nil on success")
                    
                    print("Fetch user data: Email:", user.email, "Username:", user.username, "Error:", error?.localizedDescription ?? "No error")
                } else if let error = error {
                    // Отримано помилку
                    XCTFail("Failed to fetch user data: \(error.localizedDescription)")
                } else {
                    XCTFail("No user data or error received")
                }
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSignOut() { // Тест для перевірки виходу з системи
        AuthManager.shared.signOut() // Викликаємо метод виходу
        let user = Auth.auth().currentUser // Отримуємо поточного користувача
        XCTAssertNil(user, "User should be nil after sign out") // Перевіряємо, чи користувач вийшов
        print("User signed out successfully.") // Виводимо повідомлення про успішний вихід
    }
    
    func testUpload() {
        let storageRef = Storage.storage().reference().child("test.jpg")
        let data = Data() // Тут має бути зображення, наприклад, UIImage -> Data
        
        storageRef.putData(data, metadata: nil) { metadata, error in
            if let error = error {
                print("❌ Помилка: \(error.localizedDescription)")
            } else {
                print("✅ Файл завантажено!")
            }
        }
    }

}
