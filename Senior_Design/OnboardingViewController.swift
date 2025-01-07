import UIKit

class OnboardingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue // or any color
        setupUI()
    }
    
    private func setupUI() {
        let label = UILabel()
        label.text = "Welcome to the Game!"
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let continueButton = UIButton(type: .system)
        continueButton.setTitle("Continue to Login", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueToLogin), for: .touchUpInside)
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20)
        ])
    }
    
    @objc private func continueToLogin() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
}
