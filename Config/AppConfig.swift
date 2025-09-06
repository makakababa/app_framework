import Foundation

struct AppConfig {
    // MARK: - API Configuration
    // use openAI

    static let llmAPIKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String ?? ""
    static let baseURL = "https://api.openai.com/v1/chat/completions"
    static let modelName = "gpt-4.1-nano"
    
    // MARK: - App Settings
    static let maxTutoringSessions = 50
    static let defaultDifficulty = 3
    
    // MARK: - Validation
    static var isAPIKeyConfigured: Bool {
        return !llmAPIKey.isEmpty && llmAPIKey != "YOUR_OPENAI_API_KEY"
    }
}
