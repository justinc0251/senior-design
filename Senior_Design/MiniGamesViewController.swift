import UIKit

class MiniGamesViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let cardHeight: CGFloat = 160
        static let cardCornerRadius: CGFloat = 16
        static let cardSpacing: CGFloat = 24
        static let contentPadding: CGFloat = 24
        static let accentWidth: CGFloat = 8
        static let iconSize: CGFloat = 60
        static let buttonHeight: CGFloat = 40
        static let buttonWidth: CGFloat = 100
    }
    
    // MARK: - Types
    
    private struct GameInfo {
        let title: String
        let iconName: String
        let description: String
        let accentColor: UIColor
        var isCompleted: Bool = false
    }
    
    // MARK: - Properties
    
    private var games: [GameInfo] = [
        GameInfo(
            title: "Connections",
            iconName: "square.grid.2x2",
            description: "Sort items into correct waste categories.",
            accentColor: UIColor(red: 87/255, green: 155/255, blue: 252/255, alpha: 1.0)
        ),
        GameInfo(
            title: "Recycle Catcher", 
            iconName: "arrow.3.trianglepath",
            description: "Catch falling recyclables and sort them into bins.",
            accentColor: UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
        ),
        GameInfo(
            title: "Trivia",
            iconName: "lightbulb",
            description: "Test your knowledge on sustainability topics.",
            accentColor: UIColor(red: 255/255, green: 184/255, blue: 76/255, alpha: 1.0)
        )
    ]
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private var gameCards: [UIView] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAccessibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkGameCompletion()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGradientBackground()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 245/255, green: 247/255, blue: 250/255, alpha: 1.0)
        
        setupNavigationBar()
        setupHeaderLabels()
        setupScrollView()
        setupGameCards()
    }
    
    private func setupGradientBackground() {
        view.layer.sublayers?.removeAll(where: { $0.name == "backgroundGradient" })
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "backgroundGradient"
        gradientLayer.colors = [
            UIColor(red: 245/255, green: 247/255, blue: 250/255, alpha: 1.0).cgColor,
            UIColor(red: 235/255, green: 240/255, blue: 245/255, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .systemGreen
    }
    
    private func setupHeaderLabels() {
        titleLabel.text = "Mini Games"
        titleLabel.font = UIFont(name: "Sen-Bold", size: 32) ?? UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.contentPadding)
        ])
        
        subtitleLabel.text = "Learn while having fun!"
        subtitleLabel.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])
    }
    
    private func setupScrollView() {
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupGameCards() {
        stackView.axis = .vertical
        stackView.spacing = Constants.cardSpacing
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.contentPadding),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.contentPadding),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.contentPadding)
        ])
        
        for (index, game) in games.enumerated() {
            let cardView = createGameCard(game: game, index: index)
            stackView.addArrangedSubview(cardView)
            gameCards.append(cardView)
            
            cardView.heightAnchor.constraint(equalToConstant: Constants.cardHeight).isActive = true
        }
    }
    
    private func createGameCard(game: GameInfo, index: Int) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = Constants.cardCornerRadius
        cardView.clipsToBounds = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 6)
        cardView.layer.shadowRadius = 16
        cardView.layer.shadowOpacity = 1
        
        let accentView = UIView()
        accentView.backgroundColor = game.accentColor
        accentView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = .white
        iconContainer.layer.cornerRadius = Constants.iconSize / 2
        iconContainer.layer.borderWidth = 2
        iconContainer.layer.borderColor = UIColor(white: 0.95, alpha: 1.0).cgColor
        iconContainer.clipsToBounds = true
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = game.accentColor
        iconImageView.image = UIImage(systemName: game.iconName)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = game.title
        titleLabel.font = UIFont(name: "Sen-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = game.description
        descriptionLabel.font = UIFont(name: "Sen-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let playButton = UIButton(type: .system)
        playButton.setTitle("Play", for: .normal)
        playButton.titleLabel?.font = UIFont(name: "Sen-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        playButton.backgroundColor = game.accentColor
        playButton.setTitleColor(.white, for: .normal)
        playButton.layer.cornerRadius = Constants.buttonHeight / 2
        playButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        playButton.tag = index
        playButton.addTarget(self, action: #selector(gameButtonTapped(_:)), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        let arrowConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let arrowImage = UIImage(systemName: "arrow.right", withConfiguration: arrowConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        playButton.setImage(arrowImage, for: .normal)
        playButton.tintColor = .white
        playButton.semanticContentAttribute = .forceRightToLeft
        playButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        cardView.addGestureRecognizer(tapGesture)
        cardView.tag = index
        cardView.isUserInteractionEnabled = true
        
        cardView.addSubview(accentView)
        cardView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(playButton)
        
        NSLayoutConstraint.activate([
            accentView.topAnchor.constraint(equalTo: cardView.topAnchor),
            accentView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            accentView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            accentView.widthAnchor.constraint(equalToConstant: Constants.accentWidth),
            
            iconContainer.leadingAnchor.constraint(equalTo: accentView.trailingAnchor, constant: 16),
            iconContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            iconContainer.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconContainer.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: playButton.topAnchor, constant: -12),
            
            playButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            playButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            playButton.widthAnchor.constraint(equalToConstant: Constants.buttonWidth),
            playButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
        
        let pressDown = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)))
        pressDown.minimumPressDuration = 0.1
        cardView.addGestureRecognizer(pressDown)
        
        return cardView
    }
    
    private func setupAccessibility() {
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits = .header
        titleLabel.accessibilityLabel = "Mini Games"
        
        subtitleLabel.isAccessibilityElement = true
        subtitleLabel.accessibilityLabel = "Learn while having fun!"
        
        for (index, game) in games.enumerated() {
            if let card = gameCards.first(where: { $0.tag == index }) {
                card.isAccessibilityElement = true
                card.accessibilityLabel = "\(game.title) game. \(game.description)"
                card.accessibilityHint = "Double-tap to play this game"
                card.accessibilityTraits = .button
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func handlePress(_ gesture: UILongPressGestureRecognizer) {
        guard let cardView = gesture.view else { return }
        
        switch gesture.state {
        case .began:
            UIView.animate(withDuration: 0.2) {
                cardView.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
                cardView.layer.shadowOpacity = 0.7
            }
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.2) {
                cardView.transform = .identity
                cardView.layer.shadowOpacity = 1.0
            }
        default:
            break
        }
    }
    
    @objc private func cardTapped(_ sender: UITapGestureRecognizer) {
        if let view = sender.view {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            openGame(at: view.tag)
        }
    }
    
    @objc private func gameButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        openGame(at: sender.tag)
    }
    
    private func openGame(at index: Int) {
        switch index {
        case 0:
            let connectionsVC = ConnectionsGameViewController()
            navigationController?.pushViewController(connectionsVC, animated: true)
        case 1:
            let catcherVC = CatcherGameViewController()
            navigationController?.pushViewController(catcherVC, animated: true)
        case 2:
            let quizVC = QuizGameViewController()
            navigationController?.pushViewController(quizVC, animated: true)
        default:
            break
        }
    }
    
    // MARK: - Game Progress
    
    private func checkGameCompletion() {
        for index in 0..<games.count {
            let isCompleted = UserDefaults.standard.bool(forKey: "game_\(index)_completed")
            updateGameCompletion(for: index, completed: isCompleted)
        }
    }
    
    func updateGameCompletion(for gameIndex: Int, completed: Bool) {
        if gameIndex < games.count {
            games[gameIndex].isCompleted = completed
        }
    }
}