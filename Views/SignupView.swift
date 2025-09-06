import SwiftUI
import FirebaseAuth
import UIKit

struct SignupView: View {
    @ObservedObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = "Failed to create account. Please try again."
    
    // Add notification observer for signup failures
    private func setupNotifications() {
        NotificationCenter.default.addObserver(forName: Notification.Name("LoginFailed"), object: nil, queue: .main) { notification in
            self.isLoading = false
            
            // Check if there's a custom error message
            if let userInfo = notification.userInfo,
               let message = userInfo["message"] as? String {
                self.errorMessage = message
            } else {
                self.errorMessage = "Failed to create account. Please try again."
            }
            
            self.showError = true
        }
    }
    
    var body: some View {
        ZStack {
            // Kid-friendly bright background
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.98, blue: 1.0),
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.97, green: 0.95, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // App logo/title
                VStack(spacing: 10) {
                    Image(systemName: "star.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.green, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Join the Fun!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Start learning math today!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)
                
                // Input fields
                VStack(spacing: 15) {
                    TextField("Email", text: $authVM.email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.green.opacity(0.3), lineWidth: 2)
                        )
                        .foregroundColor(.black)
                        .shadow(color: Color.gray.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    SecureField("Password", text: $authVM.password)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.green.opacity(0.3), lineWidth: 2)
                        )
                        .foregroundColor(.black)
                        .shadow(color: Color.gray.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.green.opacity(0.3), lineWidth: 2)
                        )
                        .foregroundColor(.black)
                        .shadow(color: Color.gray.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                
                // Signup button
                Button {
                    if validateForm() {
                        withAnimation {
                            isLoading = true
                        }
                        authVM.signup()
                    }
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 5)
                        }
                        Text("Create Account")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [Color.green, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(isLoading)
                
                // Back to login link
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    
                    Button("Log In") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
                .font(.subheadline)
                .padding(.top, 10)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 30)
            .alert(isPresented: $showError) {
                Alert(title: Text("Signup Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                setupNotifications()
            }
        }
    }
    
    private func validateForm() -> Bool {
        // Check if passwords match
        if authVM.password != confirmPassword {
            errorMessage = "Passwords do not match"
            showError = true
            return false
        }
        
        // Check if password is strong enough (at least 6 characters)
        if authVM.password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return false
        }
        
        // Check if email is valid
        if !isValidEmail(authVM.email) {
            errorMessage = "Please enter a valid email address"
            showError = true
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

