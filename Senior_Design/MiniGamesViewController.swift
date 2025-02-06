import UIKit

class MiniGamesViewController: UIViewController {
    
    // Only three titles
    private let gameTitles = [
        "Connections",
        "Recycle Catcher",
        "Trivia"
    ]

    // Replace this with your actual image name if desired
    private let placeholderImageName = "placeholder"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTitleLabel()
        setupVerticalGameButtons()
    }
    
    private func setupTitleLabel() {
        let titleLabel = UILabel()
        titleLabel.text = "Mini Games"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 16
            ),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupVerticalGameButtons() {
        // A vertical stack that fills available space
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        mainStackView.alignment = .fill
        mainStackView.spacing = 16
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        // Create one large button per game, stacked vertically
        for (index, title) in gameTitles.enumerated() {
            let button = createGameButton(title: title, tag: index)
            mainStackView.addArrangedSubview(button)
        }
        
        // Constrain the stack from below the title label to the bottom
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 80
            ),
            mainStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),
            mainStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            ),
            mainStackView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            )
        ])
    }
    
    private func createGameButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        
        // Create a vertical stack inside the button with an image and a label
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        
        let imageView = UIImageView(image: UIImage(named: placeholderImageName))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        
        button.addSubview(stackView)
        
        // Center the stack inside the button
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        // Tap action
        button.addTarget(self, action: #selector(gameButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func gameButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            // Game 1 -> Connections Game
            let connectionsVC = ConnectionsGameViewController()
            navigationController?.pushViewController(connectionsVC, animated: true)
        case 1:
            // Game 2 -> Catcher Game
            let catcherVC = CatcherGameViewController()
            navigationController?.pushViewController(catcherVC, animated: true)
        case 2:
            // Game 3 -> Quiz Game
            let quizVC = QuizGameViewController()
            navigationController?.pushViewController(quizVC, animated: true)
        default:
            break
        }
    }
}
