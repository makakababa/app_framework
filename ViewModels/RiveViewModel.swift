import SwiftUI
import RiveRuntime

struct RiveAnimationView: View {
    let fileName: String
    @State private var hasError = false
    
    init(fileName: String = "icon01") {
        self.fileName = fileName
    }
    
    var body: some View {
        Group {
            if hasError {
                // Fallback to system icon if Rive fails
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            } else {
                RiveViewModel(fileName: fileName).view()
                    .onAppear {
                        print("✅ Displaying Rive animation: \(fileName)")
                        
                        // Check if the file exists in the bundle
                        if Bundle.main.url(forResource: fileName, withExtension: "riv") == nil {
                            print("❌ Rive file not found in bundle: \(fileName).riv")
                            hasError = true
                        } else {
                            print("✅ Rive file found in bundle: \(fileName).riv")
                        }
                    }
                    .onDisappear {
                        print("🔄 Rive animation disappeared: \(fileName)")
                    }
            }
        }
    }
}
