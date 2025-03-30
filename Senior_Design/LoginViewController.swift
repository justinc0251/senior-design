import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit

class LoginViewController: UIViewController {
    
    // MARK: - Properties for Apple Sign In
    private var currentNonce: String?
    
    // MARK: - Theme Colors
    
    private enum Theme {
        static let backgroundColor = UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1.0)
        static let cardColor = UIColor.white
        static let primaryText = UIColor(red: 23/255, green: 23/255, blue: 34/255, alpha: 1.0)
        static let secondaryText = UIColor(red: 100/255, green: 100/255, blue: 110/255, alpha: 1.0)
        static let accentColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
        static let secondaryAccent = UIColor(red: 87/255, green: 155/255, blue: 252/255, alpha: 1.0)
    }
    
    // MARK: - UI Elements
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "app-logo") ?? UIImage(systemName: "leaf.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Theme.accentColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome Back!"
        label.textColor = Theme.primaryText
        label.font = UIFont(name: "Sen-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in to continue learning"
        label.textColor = Theme.secondaryText
        label.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let formContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.cardColor
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        textField.layer.cornerRadius = 12
        textField.setLeftPadding(16)
        textField.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        
        // Set placeholder with consistent color
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: placeholderAttributes)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        textField.layer.cornerRadius = 12
        textField.setLeftPadding(16)
        textField.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        
        // Set placeholder with consistent color
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: placeholderAttributes)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let togglePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = Theme.secondaryText
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let rememberMeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let rememberMeCheckbox: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.tintColor = Theme.accentColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let rememberMeLabel: UILabel = {
        let label = UILabel()
        label.text = "Remember me"
        label.textColor = Theme.secondaryText
        label.font = UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.setTitleColor(Theme.secondaryAccent, for: .normal)
        button.titleLabel?.font = UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = Theme.accentColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Sen-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = Theme.accentColor.withAlphaComponent(0.4).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "Or continue with"
        label.font = UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        label.textColor = Theme.secondaryText
        label.backgroundColor = Theme.cardColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let socialLoginStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Update the button initialization
    private let googleSignInButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        
        // Make Google icon bigger with configuration
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium) // Increased size
        let googleIcon = UIImage(systemName: "g.circle.fill", withConfiguration: config)
        button.setImage(googleIcon, for: .normal)
        button.tintColor = UIColor(red: 66/255, green: 133/255, blue: 244/255, alpha: 1.0) // Google blue
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let appleSignInButton: UIButton = {
        let button = UIButton(type: .custom) // Changed to custom
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 1
        
        // Make Apple icon bigger
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium) // Increased from 24
        let appleIcon = UIImage(systemName: "apple.logo", withConfiguration: config)
        button.setImage(appleIcon, for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let signUpContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let signUpLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't have an account? "
        label.font = UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        label.textColor = Theme.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(Theme.accentColor, for: .normal)
        button.titleLabel?.font = UIFont(name: "Sen-Bold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = Theme.backgroundColor
        
        // Add UI elements directly to the view
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(formContainer)
        
        // Form container elements
        formContainer.addSubview(emailTextField)
        formContainer.addSubview(passwordTextField)
        formContainer.addSubview(togglePasswordButton)
        
        // Remember me section
        formContainer.addSubview(rememberMeView)
        rememberMeView.addSubview(rememberMeCheckbox)
        rememberMeView.addSubview(rememberMeLabel)
        
        formContainer.addSubview(forgotPasswordButton)
        formContainer.addSubview(loginButton)
        formContainer.addSubview(dividerView)
        formContainer.addSubview(orLabel)
        
        // Social login buttons
        formContainer.addSubview(socialLoginStackView)
        socialLoginStackView.addArrangedSubview(googleSignInButton)
        socialLoginStackView.addArrangedSubview(appleSignInButton)
        
        // Sign up section
        view.addSubview(signUpContainer)
        signUpContainer.addSubview(signUpLabel)
        signUpContainer.addSubview(signUpButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let horizontalPadding: CGFloat = 24
        
        // Logo, title and subtitle - more spacing
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 60),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 40), // More spacing under logo
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Form container - more spacing under subtitle
        NSLayoutConstraint.activate([
            formContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 60), // More spacing under subtitle
            formContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            formContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding)
        ])
        
        // Email & password fields - more compact
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: formContainer.topAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 46),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 46),
            
            togglePasswordButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            togglePasswordButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: -16),
            togglePasswordButton.widthAnchor.constraint(equalToConstant: 24),
            togglePasswordButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Remember me & forgot password - more compact
        NSLayoutConstraint.activate([
            rememberMeView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 12),
            rememberMeView.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            rememberMeView.heightAnchor.constraint(equalToConstant: 24),
            
            rememberMeCheckbox.leadingAnchor.constraint(equalTo: rememberMeView.leadingAnchor),
            rememberMeCheckbox.centerYAnchor.constraint(equalTo: rememberMeView.centerYAnchor),
            rememberMeCheckbox.widthAnchor.constraint(equalToConstant: 24),
            rememberMeCheckbox.heightAnchor.constraint(equalToConstant: 24),
            
            rememberMeLabel.leadingAnchor.constraint(equalTo: rememberMeCheckbox.trailingAnchor, constant: 8),
            rememberMeLabel.centerYAnchor.constraint(equalTo: rememberMeCheckbox.centerYAnchor),
            
            forgotPasswordButton.centerYAnchor.constraint(equalTo: rememberMeView.centerYAnchor),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor)
        ])
        
        // Login button & divider - more compact
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: rememberMeView.bottomAnchor, constant: 16),
            loginButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 46),
            
            dividerView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            dividerView.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 40),
            dividerView.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -40),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            
            orLabel.centerXAnchor.constraint(equalTo: formContainer.centerXAnchor),
            orLabel.centerYAnchor.constraint(equalTo: dividerView.centerYAnchor),
            orLabel.widthAnchor.constraint(equalToConstant: 120)
        ])
        
        // Social login buttons - more compact
        NSLayoutConstraint.activate([
            socialLoginStackView.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 16),
            socialLoginStackView.centerXAnchor.constraint(equalTo: formContainer.centerXAnchor),
            socialLoginStackView.heightAnchor.constraint(equalToConstant: 46),
            socialLoginStackView.widthAnchor.constraint(equalToConstant: 200),
            
            formContainer.bottomAnchor.constraint(equalTo: socialLoginStackView.bottomAnchor, constant: 16)
        ])
        
        // Sign up container - attached to the bottom of the safe area
        NSLayoutConstraint.activate([
            signUpContainer.topAnchor.constraint(equalTo: formContainer.bottomAnchor, constant: 16),
            signUpContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpContainer.heightAnchor.constraint(equalToConstant: 20),
            
            signUpLabel.leadingAnchor.constraint(equalTo: signUpContainer.leadingAnchor),
            signUpLabel.centerYAnchor.constraint(equalTo: signUpContainer.centerYAnchor),
            
            signUpButton.leadingAnchor.constraint(equalTo: signUpLabel.trailingAnchor),
            signUpButton.centerYAnchor.constraint(equalTo: signUpContainer.centerYAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: signUpContainer.trailingAnchor),
            
            signUpContainer.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    private func setupActions() {
        rememberMeCheckbox.addTarget(self, action: #selector(rememberMeTapped), for: .touchUpInside)
        togglePasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        googleSignInButton.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
        appleSignInButton.addTarget(self, action: #selector(handleAppleSignIn), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        
        // Add tap gesture to rememberMeView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rememberMeViewTapped))
        rememberMeView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func rememberMeTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        animateButtonPress(sender)
    }
    
    @objc private func rememberMeViewTapped() {
        rememberMeCheckbox.isSelected.toggle()
        animateButtonPress(rememberMeCheckbox)
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        togglePasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
        animateButtonPress(togglePasswordButton)
    }
    
    @objc private func loginTapped() {
        animateButtonPress(loginButton)
        // Implement your login logic here
    }
    
    @objc private func forgotPasswordTapped() {
        animateButtonPress(forgotPasswordButton)
        // Implement your forgot password logic here
    }
    
    @objc private func signUpTapped() {
        animateButtonPress(signUpButton)
        // Implement your sign up navigation logic here
    }
    
    @objc private func handleGoogleSignIn() {
        animateButtonPress(googleSignInButton)
        signInWithGoogle()
    }
    
    @objc private func handleAppleSignIn() {
        animateButtonPress(appleSignInButton)
        
        // Generate a nonce for secure authorization
        currentNonce = randomNonceString()
        guard let nonce = currentNonce else { return }
        
        // Create the Apple sign-in request
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        // Start the authorization flow
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func animateButtonPress(_ button: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }
    
    // MARK: - Google Sign-In
    
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
                "provider": "google"
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
                
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                self?.transitionToMainApp()
            }
        }
    }
    
    // Handle saving Apple sign in user data
    private func saveAppleUserData(firebaseUser: User, name: String?, email: String?) {
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(firebaseUser.uid)
        
        userDoc.getDocument { [weak self] document, error in
            if let error = error {
                self?.showAlert(title: "Error", message: "Failed to retrieve user data: \(error.localizedDescription)")
                return
            }
            
            var userData: [String: Any] = [
                "uid": firebaseUser.uid,
                "provider": "apple"
            ]
            
            // Add name and email if available
            if let name = name, !name.isEmpty {
                userData["name"] = name
            } else if let existingName = document?.data()?["name"] as? String {
                userData["name"] = existingName
            } else {
                userData["name"] = "Apple User"
            }
            
            if let email = email, !email.isEmpty {
                userData["email"] = email
            } else if let existingEmail = document?.data()?["email"] as? String {
                userData["email"] = existingEmail
            } else {
                userData["email"] = firebaseUser.email ?? ""
            }
            
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
                
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                self?.transitionToMainApp()
            }
        }
    }
    
    private func transitionToMainApp() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = sceneDelegate.createTabBarController()
        }
    }
    
    // MARK: - Apple Sign In Helpers
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // MARK: - Alert Helper
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - TextField Extension
extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

// MARK: - Apple Sign In Extensions
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else {
                showAlert(title: "Error", message: "Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                showAlert(title: "Error", message: "Unable to fetch identity token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                showAlert(title: "Error", message: "Unable to serialize token string from data")
                return
            }
            
            // Create credentials
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                     idToken: idTokenString,
                                                     rawNonce: nonce)
            
            // Sign in with Firebase
            Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.showAlert(title: "Authentication Error", message: error.localizedDescription)
                    return
                }
                
                guard let firebaseUser = authResult?.user else {
                    self.showAlert(title: "Error", message: "Unable to retrieve user information")
                    return
                }
                
                // Get name from Apple credential if available
                var displayName = ""
                if let fullName = appleIDCredential.fullName {
                    let firstName = fullName.givenName ?? ""
                    let lastName = fullName.familyName ?? ""
                    if !firstName.isEmpty || !lastName.isEmpty {
                        displayName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
                
                // Get email if available
                let email = appleIDCredential.email
                
                // Save user details
                self.saveAppleUserData(firebaseUser: firebaseUser, name: displayName, email: email)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showAlert(title: "Sign In Error", message: error.localizedDescription)
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}