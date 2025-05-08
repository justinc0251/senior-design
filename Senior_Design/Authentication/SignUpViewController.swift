import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

extension UIColor {
    func toHex() -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(
            format: "#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)
        )
    }
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

class SignUpViewController: UIViewController {
    
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
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Account"
        label.textColor = Theme.primaryText
        label.font = UIFont(name: "Sen-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Join the waste recycling community"
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
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        textField.layer.cornerRadius = 12
        textField.setLeftPadding(16)
        textField.textColor = .black
        textField.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Full Name", attributes: placeholderAttributes)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        textField.layer.cornerRadius = 12
        textField.setLeftPadding(16)
        textField.textColor = .black
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
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        textField.layer.cornerRadius = 12
        textField.setLeftPadding(16)
        textField.textColor = .black
        textField.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: placeholderAttributes)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        textField.layer.cornerRadius = 12
        textField.setLeftPadding(16)
        textField.textColor = .black
        textField.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: placeholderAttributes)
        
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
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
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
    
    private let loginContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "Already have an account? "
        label.font = UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        label.textColor = Theme.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
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
        navigationController?.navigationBar.tintColor = Theme.accentColor
        navigationItem.backButtonTitle = ""
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(formContainer)
        
        formContainer.addSubview(nameTextField)
        formContainer.addSubview(emailTextField)
        formContainer.addSubview(passwordTextField)
        formContainer.addSubview(confirmPasswordTextField)
        formContainer.addSubview(togglePasswordButton)
        formContainer.addSubview(signUpButton)
        
        view.addSubview(loginContainer)
        loginContainer.addSubview(loginLabel)
        loginContainer.addSubview(loginButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let horizontalPadding: CGFloat = 24
        
        // Title and subtitle
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Form container
        NSLayoutConstraint.activate([
            formContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            formContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            formContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding)
        ])
        
        // Name, email, password fields
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: formContainer.topAnchor, constant: 16),
            nameTextField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 46),
            
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 12),
            emailTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 46),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12),
            passwordTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 46),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 12),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 46),
            
            togglePasswordButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            togglePasswordButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: -16),
            togglePasswordButton.widthAnchor.constraint(equalToConstant: 24),
            togglePasswordButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Sign up button
        NSLayoutConstraint.activate([
            signUpButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 20),
            signUpButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 46),
            
            formContainer.bottomAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 16)
        ])
        
        // Login container
        NSLayoutConstraint.activate([
            loginContainer.topAnchor.constraint(equalTo: formContainer.bottomAnchor, constant: 20),
            loginContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginContainer.heightAnchor.constraint(equalToConstant: 20),
            
            loginLabel.leadingAnchor.constraint(equalTo: loginContainer.leadingAnchor),
            loginLabel.centerYAnchor.constraint(equalTo: loginContainer.centerYAnchor),
            
            loginButton.leadingAnchor.constraint(equalTo: loginLabel.trailingAnchor),
            loginButton.centerYAnchor.constraint(equalTo: loginContainer.centerYAnchor),
            loginButton.trailingAnchor.constraint(equalTo: loginContainer.trailingAnchor),
            
            loginContainer.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        togglePasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        confirmPasswordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        togglePasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
        animateButtonPress(togglePasswordButton)
    }
    
    @objc private func signUpTapped() {
        animateButtonPress(signUpButton)
        
        // Validate form fields
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter your name")
            return
        }
        
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter your email")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter a password")
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please confirm your password")
            return
        }
        
        if password != confirmPassword {
            showAlert(title: "Error", message: "Passwords do not match")
            return
        }
        
        if password.count < 6 {
            showAlert(title: "Error", message: "Password must be at least 6 characters")
            return
        }
        
        // Create the user in Firebase
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            guard let firebaseUser = result?.user else {
                self.showAlert(title: "Error", message: "Failed to create user account")
                return
            }
            
            // Save user data to Firestore
            self.saveUserDataToFirestore(user: firebaseUser, name: name)
        }
    }
    
    @objc private func loginTapped() {
        animateButtonPress(loginButton)
        navigationController?.popViewController(animated: true)
    }
    
    private func colorForUser(email: String) -> UIColor {
            let colors: [UIColor] = [
                UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0),  // accent color
                UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0),    // bright red
                UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1.0),  // bright yellow
                UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0),   // blue
                UIColor(red: 155/255, green: 89/255, blue: 182/255, alpha: 1.0),   // purple
                UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1.0),    // orange
                UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0),   // emerald green
                UIColor(red: 26/255, green: 188/255, blue: 156/255, alpha: 1.0),   // teal
                UIColor(red: 142/255, green: 68/255, blue: 173/255, alpha: 1.0),   // deep purple
                UIColor(red: 41/255, green: 128/255, blue: 185/255, alpha: 1.0),    // deep blue
                UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1.0),   // deep green
                UIColor(red: 211/255, green: 84/255, blue: 0/255, alpha: 1.0),      // deep orange
                UIColor(red: 243/255, green: 156/255, blue: 18/255, alpha: 1.0),    // bright orange
                UIColor(red: 192/255, green: 57/255, blue: 43/255, alpha: 1.0),   // deep red
                UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0),      // dark blue
                UIColor(red: 93/255, green: 173/255, blue: 226/255, alpha: 1.0),    // light blue
                UIColor(red: 214/255, green: 48/255, blue: 49/255, alpha: 1.0),    // dark red
                UIColor(red: 255/255, green: 195/255, blue: 18/255, alpha: 1.0),    // bright yellow
                UIColor(red: 196/255, green: 229/255, blue: 56/255, alpha: 1.0),    // lime green
                UIColor(red: 18/255, green: 203/255, blue: 196/255, alpha: 1.0),    // turquoise
                UIColor(red: 253/255, green: 121/255, blue: 168/255, alpha: 1.0)     // pink
            ]
            
            let hash = email.unicodeScalars.map { $0.value }.reduce(0, +)
            let index = Int(hash) % colors.count
            return colors[index]
        }
    
    private func saveUserDataToFirestore(user: User, name: String) {
        let db = Firestore.firestore()
        let username = generateUsername(from: name)
        let userColor = colorForUser(email: user.email ?? "")
        guard let colorHex = userColor.toHex() else { return }
        
        let userData: [String: Any] = [
            "uid": user.uid,
            "name": name,
            "username": username,
            "email": user.email ?? "",
            "profileColor": colorHex,
            "provider": "email",
            "score": 0,
            "followers": [],
            "following": [],
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(user.uid).setData(userData) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to save user data: \(error.localizedDescription)")
                return
            }
            
            UserDefaults.standard.set(user.uid, forKey: "currentUserId")
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            
            self.transitionToMainApp()
        }
    }
    
    private func generateUsername(from name: String) -> String {
        // Remove spaces and special characters, convert to lowercase
        let sanitized = name.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined()
        
        // If too short, append random number
        if sanitized.count < 4 {
            let randomNum = Int.random(in: 1000...9999)
            return "user\(sanitized)\(randomNum)"
        }
        
        // Add random 3-digit number at the end to ensure uniqueness
        let randomNum = Int.random(in: 100...999)
        return "\(sanitized)\(randomNum)"
    }
    
    private func transitionToMainApp() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = sceneDelegate.createTabBarController()
        }
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
    
    // MARK: - Alert Helper
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
