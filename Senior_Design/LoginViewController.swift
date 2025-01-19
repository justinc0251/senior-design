import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {

    private let googleSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray
        setupUI()
    }
    
    private func setupUI() {
        // MARK: - Title Label
        let label = UILabel()
        label.text = "Login Screen"
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40)
        ])

        // MARK: - Google Sign-In Button
        view.addSubview(googleSignInButton)

        NSLayoutConstraint.activate([
            googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleSignInButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGoogleSignIn))
        googleSignInButton.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleGoogleSignIn() {
        signInWithGoogle()
    }
    
    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            showAlert(title: "Error", message: "Missing client ID in Firebase configuration.")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(title: "Sign-In Error", message: error.localizedDescription)
                return
            }

            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                self.showAlert(title: "Error", message: "Unable to retrieve user information.")
                return
            }

            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showAlert(title: "Firebase Sign-In Error", message: error.localizedDescription)
                    return
                }

                guard let firebaseUser = authResult?.user else {
                    self.showAlert(title: "Error", message: "Unable to retrieve authenticated user.")
                    return
                }

                self.saveUserData(firebaseUser: firebaseUser, user: user)
            }
        }
    }
    
    private func saveUserData(firebaseUser: User, user: GIDGoogleUser) {
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(firebaseUser.uid)

        userDoc.getDocument { [weak self] document, error in
            if let error = error {
                self?.showAlert(title: "Error", message: "Failed to retrieve user data: \(error.localizedDescription)")
                return
            }

            var userData: [String: Any] = [
                "uid": firebaseUser.uid,
                "name": user.profile?.name ?? "Anonymous",
                "email": user.profile?.email ?? "",
                "photoURL": user.profile?.imageURL(withDimension: 200)?.absoluteString ?? "",
            ]

            // Check if the document exists and retrieve the score
            if let document = document, document.exists, let existingScore = document.data()?["score"] as? Int {
                userData["score"] = existingScore
            } else {
                userData["score"] = 0 // Initialize score for new users
            }

            userDoc.setData(userData, merge: true) { [weak self] error in
                if let error = error {
                    self?.showAlert(title: "Error", message: "Failed to save user data: \(error.localizedDescription)")
                    return
                }

                print("User data successfully saved!")
                self?.transitionToMainApp()
            }
        }
    }
    
    private func transitionToMainApp() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = sceneDelegate.createTabBarController()
        }
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
