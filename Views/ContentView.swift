import SwiftUI

struct ContentView: View {
    @StateObject var authVM = AuthViewModel()


    var body: some View {
        if authVM.isLoading {
            SplashView()
        } else if authVM.isLoggedIn {
            TabView {
                HomeView(authVM: authVM)
                    .tabItem {
                        Image(systemName: "function")
                        Text("Course")
                    }
                ProfileView(authVM: authVM)
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
            }
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.white
                appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
                UITabBar.appearance().tintColor = UIColor.systemBlue
                UITabBar.appearance().unselectedItemTintColor = UIColor.gray
            }
        } else {
            LoginView(authVM: authVM)
        }
    }
}

