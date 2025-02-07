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
            print("Error: Missing client ID in Firebase configuration.")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, error in
            guard let self = self else { return }
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                return
            }

            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Error: Missing Google user or tokens.")
                return
            }

            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign-in error: \(error.localizedDescription)")
                    return
                }

                guard let firebaseUser = authResult?.user else { return }
                let db = Firestore.firestore()
                let userDoc = db.collection("users").document(firebaseUser.uid)

                userDoc.setData([
                    "uid": firebaseUser.uid,
                    "name": user.profile?.name ?? "Anonymous",
                    "email": user.profile?.email ?? "",
                    "photoURL": user.profile?.imageURL(withDimension: 200)?.absoluteString ?? "",
                    "score": 0
                ], merge: true) { error in
                    if let error = error {
                        print("Error saving user data: \(error.localizedDescription)")
                    } else {
                        print("User data successfully saved!")
                        let gameVC = ConnectionsGameViewController()
                        self.navigationController?.pushViewController(gameVC, animated: true)
                    }
                }
            }
        }
    }
}
