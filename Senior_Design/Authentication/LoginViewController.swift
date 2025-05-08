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
        imageView.image = UIImage(named: "literracy") ?? UIImage(systemName: "leaf.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Theme.accentColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome!"
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
        textField.textColor = .black
        textField.setLeftPaddingPoints(16)
        textField.keyboardType = .emailAddress
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        textField.layer.cornerRadius = 12
        textField.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)

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
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.setLeftPaddingPoints(16)
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        textField.layer.cornerRadius = 12
        textField.textColor = .black
        textField.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)

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

       private let rememberMeCheckbox: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.tintColor = Theme.accentColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()

    private let rememberMeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
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

    private let googleSignInButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor

        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)
        let googleIcon = UIImage(systemName: "g.circle.fill", withConfiguration: config) ?? UIImage(named: "google")
        button.setImage(googleIcon, for: .normal)
        button.tintColor = UIColor(red: 66/255, green: 133/255, blue: 244/255, alpha: 1.0)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let appleSignInButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 1

        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
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

    private let guestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Explore as Guest", for: .normal)
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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = Theme.backgroundColor

        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(formContainer)

        formContainer.addSubview(emailTextField)
        formContainer.addSubview(passwordTextField)
        formContainer.addSubview(togglePasswordButton)

        formContainer.addSubview(rememberMeView)
        rememberMeView.addSubview(rememberMeCheckbox)
        rememberMeView.addSubview(rememberMeLabel)

        formContainer.addSubview(forgotPasswordButton)
        formContainer.addSubview(loginButton)
        formContainer.addSubview(dividerView)
        formContainer.addSubview(orLabel)

        formContainer.addSubview(socialLoginStackView)
        socialLoginStackView.addArrangedSubview(googleSignInButton)
        socialLoginStackView.addArrangedSubview(appleSignInButton)

        view.addSubview(signUpContainer)
        signUpContainer.addSubview(signUpLabel)
        signUpContainer.addSubview(signUpButton)

        view.addSubview(guestButton)

        setupConstraints()
    }

    private func setupConstraints() {
        let horizontalPadding: CGFloat = 24

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            formContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            formContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            formContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding)
        ])

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

        NSLayoutConstraint.activate([
            rememberMeView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 12),
            rememberMeView.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            rememberMeView.heightAnchor.constraint(equalToConstant: 30),
            rememberMeView.widthAnchor.constraint(equalToConstant: 120),

            rememberMeCheckbox.leadingAnchor.constraint(equalTo: rememberMeView.leadingAnchor),
            rememberMeCheckbox.centerYAnchor.constraint(equalTo: rememberMeView.centerYAnchor),
            rememberMeCheckbox.widthAnchor.constraint(equalToConstant: 24),
            rememberMeCheckbox.heightAnchor.constraint(equalToConstant: 24),

            rememberMeLabel.leadingAnchor.constraint(equalTo: rememberMeCheckbox.trailingAnchor, constant: 8),
            rememberMeLabel.centerYAnchor.constraint(equalTo: rememberMeCheckbox.centerYAnchor),

            forgotPasswordButton.centerYAnchor.constraint(equalTo: rememberMeView.centerYAnchor),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor)
        ])

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

        NSLayoutConstraint.activate([
            socialLoginStackView.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 16),
            socialLoginStackView.centerXAnchor.constraint(equalTo: formContainer.centerXAnchor),
            socialLoginStackView.heightAnchor.constraint(equalToConstant: 46),
            socialLoginStackView.widthAnchor.constraint(equalToConstant: 120),

            formContainer.bottomAnchor.constraint(equalTo: socialLoginStackView.bottomAnchor, constant: 16)
        ])

        NSLayoutConstraint.activate([
            signUpContainer.topAnchor.constraint(equalTo: formContainer.bottomAnchor, constant: 16),
            signUpContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpContainer.heightAnchor.constraint(equalToConstant: 20),

            signUpLabel.leadingAnchor.constraint(equalTo: signUpContainer.leadingAnchor),
            signUpLabel.centerYAnchor.constraint(equalTo: signUpContainer.centerYAnchor),

            signUpButton.leadingAnchor.constraint(equalTo: signUpLabel.trailingAnchor),
            signUpButton.centerYAnchor.constraint(equalTo: signUpContainer.centerYAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: signUpContainer.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            guestButton.topAnchor.constraint(equalTo: signUpContainer.bottomAnchor, constant: 20),
            guestButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding + 50),
            guestButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding - 50),
            guestButton.heightAnchor.constraint(equalToConstant: 46),
            guestButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
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
        guestButton.addTarget(self, action: #selector(guestButtonTapped), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rememberMeViewTapped))
        rememberMeView.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions

    @objc private func rememberMeTapped(_ sender: UIButton) {
        sender.isSelected.toggle()

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }

        print("Remember me is now: \(sender.isSelected ? "checked" : "unchecked")")
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

        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter your email")
            return
        }

        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter your password")
            return
        }

        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)

        view.isUserInteractionEnabled = false

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            self.view.isUserInteractionEnabled = true
            activityIndicator.removeFromSuperview()

            if let error = error {
                self.showAlert(title: "Sign In Error", message: error.localizedDescription)
                return
            }

            guard let user = authResult?.user else {
                self.showAlert(title: "Error", message: "Unable to retrieve user information")
                return
            }

            AuthManager.shared.currentUserId = user.uid
            AuthManager.shared.isGuest = false

            if self.rememberMeCheckbox.isSelected {
                 AuthManager.shared.isLoggedIn = true
            } else {
                 AuthManager.shared.isLoggedIn = true
            }

            self.transitionToMainApp()
        }
    }

    @objc private func forgotPasswordTapped() {
        animateButtonPress(forgotPasswordButton)
        let forgotPasswordVC = ForgotPasswordViewController()
        navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }

    @objc private func signUpTapped() {
        animateButtonPress(signUpButton)
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }

    @objc private func handleGoogleSignIn() {
        animateButtonPress(googleSignInButton)
        signInWithGoogle()
    }

    @objc private func handleAppleSignIn() {
        animateButtonPress(appleSignInButton)

        currentNonce = randomNonceString()
        guard let nonce = currentNonce else { return }

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    @objc private func guestButtonTapped() {
        print("Guest button tapped")
        AuthManager.shared.isGuest = true
        AuthManager.shared.isLoggedIn = false
        AuthManager.shared.currentUserId = nil

        animateButtonPress(guestButton)
        transitionToMainApp()
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
                if let gidError = error as? GIDSignInError, gidError.code == .canceled {
                    print("Google Sign In was canceled by the user")
                    return
                }
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
    
    private func colorForUser(email: String) -> UIColor {
        let colors: [UIColor] = [
            UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0),
            UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0),
            UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1.0),
            UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0),
            UIColor(red: 155/255, green: 89/255, blue: 182/255, alpha: 1.0),
            UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1.0),
            UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0),
            UIColor(red: 26/255, green: 188/255, blue: 156/255, alpha: 1.0)
        ]

        let hash = email.unicodeScalars.map { $0.value }.reduce(0, +)
        let index = Int(hash) % colors.count
        return colors[index]
    }

    // Update the saveUserData method for Google Sign-In
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
            
            // Add username if none exists
            if document?.data()?["username"] == nil {
                userData["username"] = self.generateUsername(from: user.profile?.name ?? "Anonymous") ?? "user123"
            }

            // Assign profileColor if it doesn't exist
            if document?.data()?["profileColor"] == nil {
                let email = user.profile?.email ?? ""
                let color = self.colorForUser(email: email)
                let colorHex = color.toHex() ?? "#4CBB7B"
                userData["profileColor"] = colorHex
            }
            
            // Initialize followers and following arrays if they don't exist
            if let document = document, document.exists {
                let existingData = document.data() ?? [:]

                if let existingScore = existingData["score"] as? Int {
                    userData["score"] = existingScore
                } else {
                    userData["score"] = 0
                }

                if let followers = existingData["followers"] as? [String] {
                    userData["followers"] = followers
                } else {
                    userData["followers"] = []
                }

                if let following = existingData["following"] as? [String] {
                    userData["following"] = following
                } else {
                    userData["following"] = []
                }
            } else {
                // New user - set defaults
                userData["score"] = 0
                userData["followers"] = []
                userData["following"] = []
                userData["createdAt"] = FieldValue.serverTimestamp()
            }

            UserDefaults.standard.set(firebaseUser.uid, forKey: "currentUserId")
            
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


    private func saveAppleUserData(firebaseUser: User, name: String?, email: String?) {
            
            // Add username if none exists
            if document?.data()?["username"] == nil {
                userData["username"] = self?.generateUsername(from: user.profile?.name ?? "Anonymous") ?? "user123"
            }

            // Assign profileColor if it doesn't exist
            if document?.data()?["profileColor"] == nil {
                let email = user.profile?.email ?? ""
                let color = self?.colorForUser(email: email)
                let colorHex = color?.toHex() ?? "#4CBB7B"
                userData["profileColor"] = colorHex
            }
            
            // Initialize followers and following arrays if they don't exist
            if let document = document, document.exists {
                let existingData = document.data() ?? [:]

                if let existingScore = existingData["score"] as? Int {
                    userData["score"] = existingScore
                } else {
                    userData["score"] = 0
                }

                if let followers = existingData["followers"] as? [String] {
                    userData["followers"] = followers
                } else {
                    userData["followers"] = []
                }

                if let following = existingData["following"] as? [String] {
                    userData["following"] = following
                } else {
                    userData["following"] = []
                }
            } else {
                // New user - set defaults
                userData["score"] = 0
                userData["followers"] = []
                userData["following"] = []
                userData["createdAt"] = FieldValue.serverTimestamp()
            }

            UserDefaults.standard.set(firebaseUser.uid, forKey: "currentUserId")
            
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

    
    // Update the saveAppleUserData method with better name handling
    private func saveAppleUserData(firebaseUser: User,
                                name: String?,
                                email: String?) {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(firebaseUser.uid)

        // Check for existing user data first
        ref.getDocument { [weak self] snapshot, _ in
            guard let self = self else { return }
            
            let resolvedName: String
            if let provided = name, !provided.trimmingCharacters(in: .whitespaces).isEmpty {
                resolvedName = provided                    // brand‑new name from Apple
                UserDefaults.standard.set(provided,
                                        forKey: "apple_user_name_\(firebaseUser.uid)")
            } else if let cached = UserDefaults.standard
                        .string(forKey: "apple_user_name_\(firebaseUser.uid)") {
                resolvedName = cached                      // previously cached name
            } else {
                resolvedName = "Apple User"                // final fallback
            }

            // ── Build the payload ───────────────────────────────────────────────
            var data: [String: Any] = [
                "uid"      : firebaseUser.uid,
                "provider" : "apple",
                "name"     : resolvedName,
                "username" : self.generateUsername(from: resolvedName),
                "email"    : email ?? firebaseUser.email ?? "",
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            // Preserve existing score if it exists
            if let existingData = snapshot?.data(), 
            let existingScore = existingData["score"] as? Int {
                data["score"] = existingScore
            } else {
                data["score"] = 0
            }
            
            // Set followers and following arrays
            if let existingData = snapshot?.data(),
            let followers = existingData["followers"] as? [String] {
                data["followers"] = followers
            } else {
                data["followers"] = []
            }
            
            if let existingData = snapshot?.data(),
            let following = existingData["following"] as? [String] {
                data["following"] = following
            } else {
                data["following"] = []
            }

            // merge keeps any other fields you're storing
            ref.setData(data, merge: true) { [weak self] error in
                // Remove loading indicator if present
                if let activityIndicator = self?.view.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
                    activityIndicator.removeFromSuperview()
                }
                self?.view.isUserInteractionEnabled = true
                
                guard error == nil else {
                    print("Error saving Apple user: \(error!.localizedDescription)")
                    return
                }
                UserDefaults.standard.set(firebaseUser.uid, forKey: "currentUserId")
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                self?.transitionToMainApp()
            }
        }
    }

    private func handleFirestoreSaveCompletion(error: Error?, firebaseUser: User) {
        if let activityIndicator = self.view.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
            activityIndicator.removeFromSuperview()
        }
        self.view.isUserInteractionEnabled = true

        if let error = error {
            showAlert(title: "Error", message: "Failed to save user data: \(error.localizedDescription)")
            return
        }

        print("User data saved/updated successfully for \(firebaseUser.providerData.first?.providerID ?? "unknown")")
        AuthManager.shared.currentUserId = firebaseUser.uid
        AuthManager.shared.isLoggedIn = true
        AuthManager.shared.isGuest = false
        transitionToMainApp()
    }


    private func generateUsername(from name: String) -> String {
        let sanitized = name.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined()
            .prefix(15)

        let baseUsername = sanitized.count < 4 ? "user\(sanitized)" : String(sanitized)

        let randomNum = Int.random(in: 100...999)
        return "\(baseUsername)\(randomNum)"
    }

    private func transitionToMainApp() {
        print("Transitioning to main app...")
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            print("Error: Could not get SceneDelegate.")
             let alert = UIAlertController(title: "Navigation Error", message: "Could not transition to the main application screen.", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "OK", style: .default))
             present(alert, animated: true)
            return
        }
        let mainTabBarController = sceneDelegate.createTabBarController()

        DispatchQueue.main.async {
             if let window = self.view.window {
                 window.rootViewController = mainTabBarController
                 UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
             } else {
                 sceneDelegate.window?.rootViewController = mainTabBarController
                 sceneDelegate.window?.makeKeyAndVisible()
             }
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
            String(format: "%02x", $0)
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

            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                     idToken: idTokenString,
                                                     rawNonce: nonce)

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

                var displayName: String?
                if let fullName = appleIDCredential.fullName {
                    let first = fullName.givenName ?? ""
                    let last = fullName.familyName ?? ""
                    let joined = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
                    if !joined.isEmpty {
                        displayName = joined
                    }
                }
                let email = appleIDCredential.email

                self.saveAppleUserData(firebaseUser: firebaseUser, name: displayName, email: email)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let authError = error as? ASAuthorizationError,
           authError.code == .canceled {
            print("User canceled the Apple login flow.")
            return
        }

        print("Apple Sign In failed: \(error.localizedDescription)")
        showAlert(title: "Sign In Error", message: error.localizedDescription)
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
