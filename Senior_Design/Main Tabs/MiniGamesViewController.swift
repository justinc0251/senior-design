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
        static let modalCornerRadius: CGFloat = 20
    }

    // MARK: - Types

    private struct GameInfo {
        let title: String
        let iconName: String
        let description: String
        let accentColor: UIColor
        var isCompleted: Bool = false
        let gameIdentifier: String
    }

    // MARK: - Properties

    private var games: [GameInfo] = [
        GameInfo(
            title: "Trivia",
            iconName: "lightbulb",
            description: "Test your knowledge on sustainability topics.",
            accentColor: UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0), // Green
            gameIdentifier: "trivia"
        ),
        GameInfo(
            title: "Recycle Catcher",
            iconName: "arrow.3.trianglepath",
            description: "Catch falling recyclables and sort them into bins.",
            accentColor: UIColor(red: 87/255, green: 155/255, blue: 252/255, alpha: 1.0), // Blue
            gameIdentifier: "catcher"
        ),
        GameInfo(
            title: "Connections",
            iconName: "square.grid.2x2",
            description: "Sort items into correct waste categories.",
            accentColor: UIColor(red: 255/255, green: 184/255, blue: 76/255, alpha: 1.0), // Yellow
            gameIdentifier: "connections"
        )
    ]

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private var gameCards: [UIView] = []
    private let helpButton = UIButton(type: .system)
    private var modalView: UIView?
    private var modalOverlay: UIView?

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
        setupHelpButton()
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

    private func setupHelpButton() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        helpButton.setImage(UIImage(systemName: "questionmark.circle.fill", withConfiguration: configuration), for: .normal)
        helpButton.tintColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)

        view.addSubview(helpButton)

        NSLayoutConstraint.activate([
            helpButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            helpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.contentPadding),
            helpButton.widthAnchor.constraint(equalToConstant: 44),
            helpButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupGameCards() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        gameCards.removeAll()

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

    @objc private func gameButtonTapped(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9).rotated(by: 0.03)
                sender.alpha = 0.8
            }
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2) {
                sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1).rotated(by: -0.02)
                sender.alpha = 1.0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.1) {
                sender.transform = .identity
            }
        }) { _ in
            if AuthManager.shared.isGuest {
                self.showLoginRequiredModal()
            } else {
                let gameIndex = sender.tag
                guard gameIndex >= 0 && gameIndex < self.games.count else {
                    print("Error: Invalid game index tapped.")
                    sender.isUserInteractionEnabled = true
                    return
                }
                let gameIdentifier = self.games[gameIndex].gameIdentifier
                self.openGame(withIdentifier: gameIdentifier)
            }

             sender.isUserInteractionEnabled = true
        }
    }

    @objc private func helpButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        UIView.animate(withDuration: 0.1, animations: {
            self.helpButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.helpButton.transform = .identity
            }) { _ in
                self.showHelpModal()
            }
        }
    }

    private func showHelpModal() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlay.alpha = 0
        view.addSubview(overlay)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissHelpModal))
        overlay.addGestureRecognizer(tapGesture)

        let modal = UIView()
        modal.backgroundColor = .white
        modal.layer.cornerRadius = Constants.modalCornerRadius
        modal.translatesAutoresizingMaskIntoConstraints = false
        modal.clipsToBounds = true
        modal.layer.masksToBounds = false
        modal.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        modal.layer.shadowOffset = CGSize(width: 0, height: 10)
        modal.layer.shadowRadius = 20
        modal.layer.shadowOpacity = 1
        view.addSubview(modal)

        let titleLabel = UILabel()
        titleLabel.text = "How to Play"
        titleLabel.font = UIFont(name: "Sen-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        modal.addSubview(titleLabel)

        let closeButton = UIButton(type: .system)
        let closeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: closeConfig), for: .normal)
        closeButton.tintColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(dismissHelpModal), for: .touchUpInside)
        modal.addSubview(closeButton)

        let contentText = UITextView()
        contentText.isEditable = false
        contentText.isSelectable = true
        contentText.isScrollEnabled = true
        contentText.showsVerticalScrollIndicator = true
        contentText.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        contentText.textColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1.0)
        contentText.text = """
        Welcome to the Mini Games section of our Sustainability App!

        Here you can play educational games to learn about proper waste sorting and environmental sustainability in a fun, interactive way.

        Available Games:

        • Connections: Group items into the correct waste categories (Recycle, Compost, Landfill, and Hazardous).

        • Recycle Catcher: Use the basket to catch falling recyclables and properly sort them.

        • Trivia: Test your knowledge about sustainability and waste management through multiple-choice questions.

        Playing these games will help you learn proper waste disposal methods while earning points for your profile.

        """
        contentText.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contentText.translatesAutoresizingMaskIntoConstraints = false
        modal.addSubview(contentText)

        NSLayoutConstraint.activate([
            modal.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            modal.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            modal.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modal.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            modal.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.6),

            titleLabel.topAnchor.constraint(equalTo: modal.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: modal.leadingAnchor, constant: 24),

            closeButton.topAnchor.constraint(equalTo: modal.topAnchor, constant: 24),
            closeButton.trailingAnchor.constraint(equalTo: modal.trailingAnchor, constant: -24),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            contentText.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            contentText.leadingAnchor.constraint(equalTo: modal.leadingAnchor, constant: 24),
            contentText.trailingAnchor.constraint(equalTo: modal.trailingAnchor, constant: -24),
            contentText.bottomAnchor.constraint(equalTo: modal.bottomAnchor, constant: -24)
        ])

        self.modalView = modal
        self.modalOverlay = overlay

        modal.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            modal.transform = .identity
            overlay.alpha = 1
        })
    }

    @objc private func dismissHelpModal() {
        guard let modalView = modalView, let overlay = modalOverlay else { return }

        UIView.animate(withDuration: 0.3, animations: {
            modalView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            overlay.alpha = 0
        }) { _ in
            modalView.removeFromSuperview()
            overlay.removeFromSuperview()
            self.modalView = nil
            self.modalOverlay = nil
        }
    }

    private func showLoginRequiredModal() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlay.alpha = 0
        view.addSubview(overlay)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissLoginModal))
        overlay.addGestureRecognizer(tapGesture)

        let modal = UIView()
        modal.backgroundColor = .white
        modal.layer.cornerRadius = Constants.modalCornerRadius
        modal.translatesAutoresizingMaskIntoConstraints = false
        modal.clipsToBounds = true
        modal.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        modal.layer.shadowOffset = CGSize(width: 0, height: 10)
        modal.layer.shadowRadius = 20
        modal.layer.shadowOpacity = 1
        view.addSubview(modal)

        let titleLabel = UILabel()
        titleLabel.text = "Sign In Required"
        titleLabel.font = UIFont(name: "Sen-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        modal.addSubview(titleLabel)


        let messageLabel = UILabel()
        messageLabel.text = "Please sign in or create an account to play games and track your progress."
        messageLabel.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1.0)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        modal.addSubview(messageLabel)

        let signInButton = UIButton(type: .system)
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.backgroundColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.titleLabel?.font = UIFont(name: "Sen-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        signInButton.layer.cornerRadius = 16
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.addTarget(self, action: #selector(navigateToLogin), for: .touchUpInside)
        modal.addSubview(signInButton)

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Continue as Guest", for: .normal)
        cancelButton.setTitleColor(UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0), for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(dismissLoginModal), for: .touchUpInside)
        modal.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            modal.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modal.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            modal.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            modal.heightAnchor.constraint(equalToConstant: 280),

            titleLabel.topAnchor.constraint(equalTo: modal.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: modal.centerXAnchor),


            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: modal.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: modal.trailingAnchor, constant: -24),

            signInButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 30),
            signInButton.centerXAnchor.constraint(equalTo: modal.centerXAnchor),
            signInButton.leadingAnchor.constraint(equalTo: modal.leadingAnchor, constant: 24),
            signInButton.trailingAnchor.constraint(equalTo: modal.trailingAnchor, constant: -24),
            signInButton.heightAnchor.constraint(equalToConstant: 50),

            cancelButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: modal.centerXAnchor)
        ])

        self.modalView = modal
        self.modalOverlay = overlay

        modal.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            modal.transform = .identity
            overlay.alpha = 1
        })
    }

    @objc private func dismissLoginModal() {
        guard let modalView = modalView, let overlay = modalOverlay else { return }

        UIView.animate(withDuration: 0.3, animations: {
            modalView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            overlay.alpha = 0
        }) { _ in
            modalView.removeFromSuperview()
            overlay.removeFromSuperview()
            self.modalView = nil
            self.modalOverlay = nil
        }
    }

    @objc private func navigateToLogin() {
        dismissLoginModal()
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.navigateToLogin()
    }

    private func openGame(withIdentifier identifier: String) {
        var viewControllerToPush: UIViewController?

        switch identifier {
        case "connections":
            viewControllerToPush = ConnectionsGameViewController()
        case "catcher":
            viewControllerToPush = CatcherGameViewController()
        case "trivia":
            viewControllerToPush = QuizGameViewController()
        default:
            print("Error: Unknown game identifier '\(identifier)'")
            return
        }

        if let vc = viewControllerToPush {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Game Progress

    private func checkGameCompletion() {
        for index in 0..<games.count {
            let gameIdentifier = games[index].gameIdentifier
            let isCompleted = UserDefaults.standard.bool(forKey: "game_\(gameIdentifier)_completed")
            updateGameCompletion(for: index, completed: isCompleted)
        }
    }

    func updateGameCompletion(for gameIndex: Int, completed: Bool) {
        if gameIndex < games.count {
            games[gameIndex].isCompleted = completed
        }
    }
}