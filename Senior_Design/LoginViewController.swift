import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth


class LoginViewController: UIViewController {

    // A Google Sign-In button (provided by GoogleSignIn SDK).
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
        // Ensure the Google client ID is correctly set in FirebaseApp configuration
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Error: Missing client ID in Firebase configuration.")
            return
        }
        
        // Create Google Sign-In configuration object
        let config = GIDConfiguration(clientID: clientID)
        
        // Present the Google Sign-In flow
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, error in
            guard let self = self else { return }
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                return
            }
            
            guard
                let user = signInResult?.user,
                let idToken = user.idToken?.tokenString
            else {
                print("Error: Missing Google user or tokens.")
                return
            }
            
            let accessToken = user.accessToken.tokenString

            // Exchange Google ID token and access token for Firebase credential
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )

            // Sign in to Firebase with the credential
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign in error: \(error.localizedDescription)")
                    return
                }
                
                // Successfully signed in with Google and authenticated with Firebase
                let gameVC = ConnectionsGameViewController()
                self.navigationController?.pushViewController(gameVC, animated: true)
            }
        }
    }
}
