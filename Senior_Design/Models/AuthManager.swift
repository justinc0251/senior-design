import Foundation
import FirebaseAuth

class AuthManager {
    static let shared = AuthManager()

    private let loggedInKey = "isLoggedIn"
    private let guestModeKey = "isGuestMode"
    private let userIdKey = "currentUserId"

    private init() {}

    var isLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: loggedInKey) && Auth.auth().currentUser != nil
        }
        set {
            UserDefaults.standard.set(newValue, forKey: loggedInKey)
            if newValue {
                isGuest = false
            }
        }
    }

    var isGuest: Bool {
        get {
            return UserDefaults.standard.bool(forKey: guestModeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: guestModeKey)
            if newValue {
                isLoggedIn = false
                currentUserId = nil
            }
        }
    }

    var currentUserId: String? {
         get {
             if isLoggedIn, let firebaseUserId = Auth.auth().currentUser?.uid {
                 if UserDefaults.standard.string(forKey: userIdKey) != firebaseUserId {
                     UserDefaults.standard.set(firebaseUserId, forKey: userIdKey)
                 }
                 return firebaseUserId
             }
             return isLoggedIn ? UserDefaults.standard.string(forKey: userIdKey) : nil
         }
         set {
             UserDefaults.standard.set(newValue, forKey: userIdKey)
         }
     }

    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            isGuest = false
            currentUserId = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            isLoggedIn = false
            isGuest = false
            currentUserId = nil
        }
    }
}