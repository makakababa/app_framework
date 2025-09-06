import SwiftUI
import FirebaseAuth
import UIKit

struct LoginView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = "Login failed. Please check your credentials."
    @State private var showSignup = false

    // Add notification observer for login failures
    private func setupNotifications() {
        NotificationCenter.default.addObserver(forName: Notification.Name("LoginFailed"), object: nil, queue: .main) { notification in
            self.isLoading = false
            
            // Check if there's a custom error message
            if let userInfo = notification.userInfo,
               let message = userInfo["message"] as? String {
                self.errorMessage = message
            } else {
                self.errorMessage = "Login failed. Please check your credentials."
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
                    Image(systemName: "graduationcap.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Math Tutor")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Let's learn math together!")
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
                                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        )
                        .foregroundColor(.black)
                        .shadow(color: Color.gray.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    SecureField("Password", text: $authVM.password)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        )
                        .foregroundColor(.black)
                        .shadow(color: Color.gray.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                
                // Login button
                Button {
                    withAnimation {
                        isLoading = true
                    }
                    authVM.login()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 5)
                        }
                        Text("Login")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(isLoading)
                
                // Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.3))
                    
                    Text("OR")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.3))
                }
                .padding(.vertical, 10)
                
                // Google sign-in button
                Button {
                    withAnimation {
                        isLoading = true
                    }
                    authVM.loginWithGoogle()
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 5)
                        } else {
                            Image(systemName: "g.circle.fill")
                                .font(.title3)
                                .padding(.trailing, 5)
                        }
                        Text("Sign in with Google")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(isLoading)
                
                // Sign up link
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    
                    Button("Sign Up") {
                        showSignup = true
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
                .font(.subheadline)
                .padding(.top, 10)
                .sheet(isPresented: $showSignup) {
                    SignupView(authVM: authVM)
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 30)
            .alert(isPresented: $showError) {
                Alert(title: Text("Login Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                setupNotifications()
            }
        }
    }
}
