//
//  UserManager.swift
//  LoginSystem
//
//  Created by Keto Nioradze on 29.07.25.
//

// UserManager.swift

import Foundation

class UserManager {

    static let shared = UserManager()

    private let userDefaults = UserDefaults.standard
    private let emailKey = "userEmail"
    private let loggedInKey = "isLoggedIn"

    private init() {
    }

    func saveLoginStatus(email: String, isLoggedIn: Bool) {
        userDefaults.set(email, forKey: emailKey)
        userDefaults.set(isLoggedIn, forKey: loggedInKey)
        print("UserManager: Login status saved: Email=\(email), LoggedIn=\(isLoggedIn)")
    }

    func getLoggedInUserEmail() -> String? {
        return userDefaults.string(forKey: emailKey)
    }

    func isLoggedIn() -> Bool {
        return userDefaults.bool(forKey: loggedInKey)
    }

    func clearLoginStatus() {
        userDefaults.removeObject(forKey: emailKey)
        userDefaults.set(false, forKey: loggedInKey)
        print("UserManager: Login status cleared.")
    }
}
