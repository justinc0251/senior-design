import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    // MARK: - UI Elements
    
    // Title Label
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Log In"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Container view (white rounded background)
    private let formContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Email TextField
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "EMAIL"
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Password TextField
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "PASSWORD"
        textField.isSecureTextEntry = true
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // Show/Hide Password Button (eye icon)
    private let togglePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // "Remember me" checkbox
    private let rememberMeCheckbox: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Remember me", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        // Tapping toggles isSelected
        button.addTarget(self, action: #selector(rememberMeTapped), for: .touchUpInside)
        return button
    }()
    
    // "Forgot Password" Button
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password", for: .normal)
        button.setTitleColor(UIColor.systemGreen, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Log In Button
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("LOG IN", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // "Don't have an account? SIGN UP"
    private let signUpLabelButton: UIButton = {
        let button = UIButton(type: .system)
        
        let normalText = "Don't have an account? "
        let signUpText = "SIGN UP"
        
        let attributedString = NSMutableAttributedString(
            string: normalText,
            attributes: [.foregroundColor: UIColor.darkGray,
                         .font: UIFont.systemFont(ofSize: 14)]
        )
        let signUpAttributed = NSAttributedString(
            string: signUpText,
            attributes: [.foregroundColor: UIColor.systemGreen,
                         .font: UIFont.boldSystemFont(ofSize: 14)]
        )
        attributedString.append(signUpAttributed)
        button.setAttributedTitle(attributedString, for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Or Label
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "Or"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    // Apple Sign-In Button (placeholder)
    private let appleSignInButton: UIButton = {
        let button = UIButton(type: .system)
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold, scale: .large)
        let image = UIImage(systemName: "applelogo", withConfiguration: config)
        
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black
        button.layer.cornerRadius = 32
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    
    // Custom Google Sign-In Button (replaces GIDSignInButton)
    private let googleSignInButton: UIButton = {
        let button = UIButton(type: .system)
        
        let googleImage = UIImage(named: "google")?.withRenderingMode(.alwaysOriginal)
        button.setImage(googleImage, for: .normal)
        
        button.backgroundColor = .white
        button.layer.cornerRadius = 32
        button.clipsToBounds = true
        
        // Add a black border:
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dark background
        view.backgroundColor = UIColor(red: 14/255, green: 14/255, blue: 36/255, alpha: 1.0)
        
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // 1) Title label
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // 2) Form container
        view.addSubview(formContainer)
        NSLayoutConstraint.activate([
            formContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 100),
            formContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            formContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 3) Fields and buttons inside container
        formContainer.addSubview(emailTextField)
        formContainer.addSubview(passwordTextField)
        formContainer.addSubview(togglePasswordButton)
        formContainer.addSubview(rememberMeCheckbox)
        formContainer.addSubview(forgotPasswordButton)
        formContainer.addSubview(loginButton)
        formContainer.addSubview(signUpLabelButton)
        formContainer.addSubview(orLabel)
        formContainer.addSubview(appleSignInButton)
        formContainer.addSubview(googleSignInButton)
        
        // Email
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: formContainer.topAnchor, constant: 36),
            emailTextField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -24),
            emailTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Password
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -60),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Toggle Password
        NSLayoutConstraint.activate([
            togglePasswordButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            togglePasswordButton.leadingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: 8),
            togglePasswordButton.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -24),
            togglePasswordButton.heightAnchor.constraint(equalToConstant: 24),
            togglePasswordButton.widthAnchor.constraint(equalToConstant: 24)
        ])
        
        // Remember Me
        NSLayoutConstraint.activate([
            rememberMeCheckbox.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            rememberMeCheckbox.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor)
        ])
        
        // Forgot Password
        NSLayoutConstraint.activate([
            forgotPasswordButton.centerYAnchor.constraint(equalTo: rememberMeCheckbox.centerYAnchor),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor)
        ])
        
        // Log In
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: rememberMeCheckbox.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        // Sign Up
        NSLayoutConstraint.activate([
            signUpLabelButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            signUpLabelButton.centerXAnchor.constraint(equalTo: formContainer.centerXAnchor)
        ])
        
        // Or label
        NSLayoutConstraint.activate([
            orLabel.topAnchor.constraint(equalTo: signUpLabelButton.bottomAnchor, constant: 24),
            orLabel.centerXAnchor.constraint(equalTo: formContainer.centerXAnchor)
        ])
        
        // Apple Sign-In
        NSLayoutConstraint.activate([
            appleSignInButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 16),
            appleSignInButton.trailingAnchor.constraint(equalTo: formContainer.centerXAnchor, constant: -16),
            appleSignInButton.widthAnchor.constraint(equalToConstant: 64),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        // Google Sign-In (custom button)
        NSLayoutConstraint.activate([
            googleSignInButton.centerYAnchor.constraint(equalTo: appleSignInButton.centerYAnchor),
            googleSignInButton.leadingAnchor.constraint(equalTo: formContainer.centerXAnchor, constant: 16),
            googleSignInButton.widthAnchor.constraint(equalToConstant: 64),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        // Add target for tapping the custom Google button
        googleSignInButton.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
        
        // Toggle password button action
        togglePasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
    }
    
    // MARK: - Button Actions
    
    @objc private func rememberMeTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        togglePasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    // MARK: - Google Sign-In Handling
    
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
                "photoURL": user.profile?.imageURL(withDimension: 200)?.absoluteString ?? ""
            ]
            
            // Check if the document exists and retrieve the score
            if let document = document, document.exists, let existingScore = document.data()?["score"] as? Int {
                userData["score"] = existingScore
            } else {
                userData["score"] = 0
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
    
    // MARK: - Alert Helper
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
}

#Preview {
    LoginViewController()
}
