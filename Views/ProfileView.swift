import SwiftUI

struct ProfileView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var showEditProfile = false
    
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
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header with proper spacing
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Profile")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Profile content
                    VStack(spacing: 24) {
                        // Profile avatar
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
                                .frame(width: 130, height: 130)
                                .shadow(color: Color.gray.opacity(0.2), radius: 8, x: 0, y: 4)
                            
                            if let profileImageURL = authVM.userProfile?.profileImageURL,
                               !profileImageURL.isEmpty {
                                AsyncImage(url: URL(string: profileImageURL)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 130, height: 130)
                                        .clipShape(Circle())
                                } placeholder: {
                                    ProgressView()
                                        .foregroundColor(.orange)
                                }
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 55, weight: .medium))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.orange, Color.red],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        }
                        
                        // User info
                        VStack(spacing: 8) {
                            Text(authVM.userProfile?.displayName.isEmpty == false ? authVM.userProfile?.displayName ?? "User" : authVM.user?.email ?? "User")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                            Text(authVM.userProfile?.email ?? authVM.user?.email ?? "")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        
                        
                        
                        // Profile options
                        VStack(spacing: 16) {
                            Button(action: {
                                showEditProfile = true
                            }) {
                                ProfileOptionRow(
                                    icon: "person.crop.circle.badge.plus",
                                    title: "Edit Profile",
                                    subtitle: "Update your name and photo",
                                    color: .blue
                                )
                            }
                            
                            
                            
                            ProfileOptionRow(
                                icon: "gear",
                                title: "Settings",
                                subtitle: "App preferences and settings",
                                color: .gray
                            )
                        }
                        .padding(.top, 20)
                        
                        // Logout button
                        Button(action: {
                            authVM.logout()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Logout")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.red.opacity(0.7), Color.red.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        .padding(.top, 30)
                        .padding(.bottom, 100) // Extra padding to keep above tab bar
                    }
                    .padding(.top, 40)
                }
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(authVM: authVM)
        }

    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}
