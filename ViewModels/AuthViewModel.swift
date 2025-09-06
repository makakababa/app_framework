
import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import UIKit


class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var userProfile: UserProfile?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = true
    @Published var email = ""
    @Published var password = ""
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    init() {
        checkAuthState()
        
        // Ensure splash screen shows for at least 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.minimumLoadingTimeCompleted = true
            self.updateIsLoading()
        }
    }
    
    private var minimumLoadingTimeCompleted = false
    private var authStateChecked = false
    
    private func updateIsLoading() {
        if minimumLoadingTimeCompleted && authStateChecked {
            isLoading = false
        }
    }
    
    private func checkAuthState() {
        Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.user = user
                self.isLoggedIn = user != nil
                
                if let user = user {
                    self.loadUserProfile(userId: user.uid)
                } else {
                    self.userProfile = nil
                    self.authStateChecked = true
                    self.updateIsLoading()
                }
            }
        }
    }
    
    private func loadUserProfile(userId: String) {
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    DispatchQueue.main.async {
                        self.userProfile = UserProfile(
                            displayName: data["displayName"] as? String ?? "",
                            email: data["email"] as? String ?? self.user?.email ?? "",
                            profileImageURL: data["profileImageURL"] as? String
                        )
                        self.authStateChecked = true
                        self.updateIsLoading()
                    }
                    
                    
                }
            } else {
                // Create default profile for new user
                let defaultProfile = UserProfile(
                    displayName: self.user?.displayName ?? "",
                    email: self.user?.email ?? ""
                )
                self.createUserProfile(userId: userId, profile: defaultProfile)
            }
        }
    }
    
    private func createUserProfile(userId: String, profile: UserProfile) {
        let data: [String: Any] = [
            "displayName": profile.displayName,
            "email": profile.email,
            "profileImageURL": profile.profileImageURL as Any
        ]
        
        db.collection("users").document(userId).setData(data) { error in
            DispatchQueue.main.async {
                if error == nil {
                    self.userProfile = profile
                }
                self.authStateChecked = true
                self.updateIsLoading()
            }
            
        }
    }
    
    private func uploadProfileImage(_ image: UIImage, userId: String, completion: @escaping (String?) -> Void) {
        // Compress image
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        // Create storage reference
        let storageRef = storage.reference()
        let profileImageRef = storageRef.child("profile_images/\(userId).jpg")
        
        // Upload image
        profileImageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error)")
                completion(nil)
                return
            }
            
            // Get download URL
            profileImageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error)")
                    completion(nil)
                } else if let url = url {
                    completion(url.absoluteString)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func updateUserProfile(displayName: String, profileImage: UIImage? = nil, completion: @escaping (Bool) -> Void) {
        guard let userId = user?.uid else {
            completion(false)
            return
        }
        
        var updatedProfile = userProfile ?? UserProfile(email: user?.email ?? "")
        updatedProfile.displayName = displayName
        
        // If there's a new profile image, upload it first
        if let profileImage = profileImage {
            uploadProfileImage(profileImage, userId: userId) { [weak self] imageURL in
                guard let self = self else { return }
                
                if let imageURL = imageURL {
                    updatedProfile.profileImageURL = imageURL
                    self.saveProfileToFirestore(updatedProfile, userId: userId, completion: completion)
                } else {
                    // Image upload failed, but still save the display name
                    self.saveProfileToFirestore(updatedProfile, userId: userId, completion: completion)
                }
            }
        } else {
            // No new image, just update the display name
            saveProfileToFirestore(updatedProfile, userId: userId, completion: completion)
        }
    }
    
    private func saveProfileToFirestore(_ profile: UserProfile, userId: String, completion: @escaping (Bool) -> Void) {
        let data: [String: Any] = [
            "displayName": profile.displayName,
            "email": profile.email,
            "profileImageURL": profile.profileImageURL as Any
        ]
        
        db.collection("users").document(userId).updateData(data) { error in
            DispatchQueue.main.async {
                if error == nil {
                    self.userProfile = profile
                    completion(true)
                } else {
                    print("Error updating profile: \(error?.localizedDescription ?? "Unknown error")")
                    completion(false)
                }
            }
        }
    }
    func loginWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Missing clientID")
            return
        }

        let config = GIDConfiguration(clientID: clientID)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("No root view controller found")
            return
        }

        // ✅ This is the correct call:
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Google sign-in failed: \(error)")
                // Notify UI about login failure
                NotificationCenter.default.post(name: Notification.Name("LoginFailed"), object: nil)
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                    print("Missing Google authentication tokens")
                    return
                }
            
            let accessToken = user.accessToken.tokenString // ✅ no guard needed

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign-in with Google failed: \(error)")
                    // Notify UI about login failure
                    NotificationCenter.default.post(name: Notification.Name("LoginFailed"), object: nil)
                    return
                }

                DispatchQueue.main.async {
                    self.isLoggedIn = true
                    self.user = authResult?.user
                }

                print("Google sign-in + Firebase login successful") }
                // Update your state here

            
        }
    }
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let user = result?.user {
                DispatchQueue.main.async {
                    self.user = user
                    self.isLoggedIn = true
                }
            } else {
                print("Login error: \(error?.localizedDescription ?? "Unknown error")")
                // Notify UI about login failure
                NotificationCenter.default.post(name: Notification.Name("LoginFailed"), object: nil)
            }
        }
    }

    func signup() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let user = result?.user {
                DispatchQueue.main.async {
                    self.user = user
                    self.isLoggedIn = true
                }
            } else {
                print("Signup error: \(error?.localizedDescription ?? "Unknown error")")
                // Notify UI about signup failure
                NotificationCenter.default.post(name: Notification.Name("LoginFailed"), object: nil, userInfo: ["message": error?.localizedDescription ?? "Failed to create account. Please try again."])
            }
        }
    }

    func logout() {
        try? Auth.auth().signOut()
        self.user = nil
        self.isLoggedIn = false
    }
}



