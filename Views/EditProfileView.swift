import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @ObservedObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var displayName: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
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
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Profile Photo Section
                        VStack(spacing: 16) {
                            Text("Profile Photo")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color.orange.opacity(0.3),
                                                Color.orange.opacity(0.1)
                                            ],
                                            center: .center,
                                            startRadius: 30,
                                            endRadius: 60
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                
                                if let profileImage = profileImage {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } else if let profileImageURL = authVM.userProfile?.profileImageURL,
                                          !profileImageURL.isEmpty {
                                    AsyncImage(url: URL(string: profileImageURL)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        ProgressView()
                                            .foregroundColor(.orange)
                                    }
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 50, weight: .medium))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color.orange, Color.red],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                                
                                // Edit button overlay
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.orange)
                                                    .frame(width: 36, height: 36)
                                                
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .offset(x: -8, y: -8)
                                    }
                                }
                                .frame(width: 120, height: 120)
                            }
                        }
                        
                        // Display Name Section
                        VStack(spacing: 16) {
                            Text("Display Name")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("Enter your name", text: $displayName)
                                .font(.body)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(.black)
                        }
                        
                        // Email (Read-only)
                        VStack(spacing: 16) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(authVM.userProfile?.email ?? authVM.user?.email ?? "")
                                .font(.body)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(.gray)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Loading overlay
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                            .scaleEffect(1.5)
                        
                        Text("Uploading photo...")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.8))
                    )
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.clear, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                            .scaleEffect(0.8)
                    } else {
                        Button("Save") {
                            saveProfile()
                        }
                        .foregroundColor(.orange)
                    }
                }
            }
        }
        .onAppear {
            displayName = authVM.userProfile?.displayName ?? ""
        }
        .onChange(of: selectedPhoto) { newPhoto in
            loadPhoto(from: newPhoto)
        }
        .alert("Profile Update", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loadPhoto(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profileImage = image
                    }
                }
            case .failure(let error):
                print("Failed to load photo: \(error)")
            }
        }
    }
    
    private func saveProfile() {
        isLoading = true
        
        authVM.updateUserProfile(displayName: displayName, profileImage: profileImage) { success in
            isLoading = false
            
            if success {
                alertMessage = "Profile updated successfully!"
                showAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
            } else {
                alertMessage = "Failed to update profile. Please try again."
                showAlert = true
            }
        }
    }
}