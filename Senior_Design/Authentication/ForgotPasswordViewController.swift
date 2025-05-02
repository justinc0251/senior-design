import UIKit
import Firebase
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    
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
        label.text = "Forgot Password"
        label.textColor = Theme.primaryText
        label.font = UIFont(name: "Sen-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your email to receive a password reset link"
        label.textColor = Theme.secondaryText
        label.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
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
        textField.textColor = .black
        textField.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: placeholderAttributes)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset Password", for: .normal)
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
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back to Login", for: .normal)
        button.setTitleColor(Theme.secondaryAccent, for: .normal)
        button.titleLabel?.font = UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
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
        
        formContainer.addSubview(emailTextField)
        formContainer.addSubview(resetButton)
        
        view.addSubview(backButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let horizontalPadding: CGFloat = 24
        
        // Title and subtitle
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Form container
        NSLayoutConstraint.activate([
            formContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            formContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalPadding),
            formContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalPadding)
        ])
        
        // Email field and reset button
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: formContainer.topAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 46),
            
            resetButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            resetButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            resetButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            resetButton.heightAnchor.constraint(equalToConstant: 46),
            
            formContainer.bottomAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 20)
        ])
        
        // Back button
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: formContainer.bottomAnchor, constant: 20),
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        resetButton.addTarget(self, action: #selector(resetPasswordTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func resetPasswordTapped() {
        animateButtonPress(resetButton)
        
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter your email address")
            return
        }
        
        // Show loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        // Disable interaction during API call
        view.isUserInteractionEnabled = false
        
        // Send password reset email
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            
            // Re-enable interaction and remove loading indicator
            self.view.isUserInteractionEnabled = true
            activityIndicator.removeFromSuperview()
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            // Show success alert
            let alert = UIAlertController(
                title: "Email Sent",
                message: "A password reset link has been sent to \(email). Please check your inbox.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            })
            
            self.present(alert, animated: true)
        }
    }
    
    @objc private func backButtonTapped() {
        animateButtonPress(backButton)
        navigationController?.popViewController(animated: true)
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