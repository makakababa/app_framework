//
//  FirebaseManager.swift
//  new_hats
//
//  Created by Guangrui Ma on 7/17/25.
//

import FirebaseCore
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init() {}

    func configure() {
        FirebaseApp.configure()
        
        // Configure Firestore settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings
    }
}
