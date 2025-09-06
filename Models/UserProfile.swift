import Foundation
import UIKit

struct UserProfile: Codable {
    var displayName: String
    var profileImageURL: String?
    var email: String
    
    init(displayName: String = "", email: String = "", profileImageURL: String? = nil) {
        self.displayName = displayName
        self.email = email
        self.profileImageURL = profileImageURL
    }
}