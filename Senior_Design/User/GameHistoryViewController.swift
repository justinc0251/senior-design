import UIKit
import FirebaseFirestore

class GameHistoryViewController: UIViewController {

    // MARK: - Properties
    var accentColor: UIColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
    private var allGames: [(name: String, date: Date, score: Int)] = []

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let activityStackView = UIStackView()
    private let noActivityLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        fetchGameHistory()
    }

    // MARK: - Data Fetching
    private func fetchGameHistory() {
        activityIndicator.startAnimating()
        noActivityLabel.isHidden = true
        activityStackView.isHidden = true

        GameHistoryManager.shared.fetchAllGames { [weak self] games, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                if let error = error {
                    print("Error fetching all games: \(error.localizedDescription)")
                    self.noActivityLabel.text = "Error loading history"
                    self.noActivityLabel.isHidden = false
                    return
                }

                if let games = games, !games.isEmpty {
                    self.allGames = games.sorted(by: { $0.date > $1.date })
                    self.updateGameHistoryUI()
                    self.activityStackView.isHidden = false
                } else {
                    self.noActivityLabel.text = "No games played yet"
                    self.noActivityLabel.isHidden = false
                }
            }
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)

        titleLabel.text = "Game History"
        titleLabel.font = UIFont(name: "Sen-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        contentView.addSubview(activityIndicator)

        noActivityLabel.text = "Loading history..."
        noActivityLabel.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        noActivityLabel.textColor = .darkGray
        noActivityLabel.textAlignment = .center
        noActivityLabel.isHidden = true
        noActivityLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(noActivityLabel)

        activityStackView.axis = .vertical
        activityStackView.spacing = 12
        activityStackView.distribution = .fill
        activityStackView.isHidden = true
        activityStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityStackView)

         let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissModal))
         navigationItem.rightBarButtonItem = closeButton
    }

     @objc private func dismissModal() {
         dismiss(animated: true, completion: nil)
     }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -50),

            noActivityLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            noActivityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -50),
            noActivityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            noActivityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            activityStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            activityStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            activityStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            activityStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    private func updateGameHistoryUI() {
        activityStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if allGames.isEmpty {
            noActivityLabel.text = "No games played yet"
            noActivityLabel.isHidden = false
        } else {
            noActivityLabel.isHidden = true
            for game in allGames {
                let gameView = createGameView(name: game.name, date: game.date, score: game.score)
                activityStackView.addArrangedSubview(gameView)
            }
        }
    }

    private func createGameView(name: String, date: Date, score: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 6
        container.layer.shadowOpacity = 1
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconContainer = UIView()
        iconContainer.backgroundColor = accentColor.withAlphaComponent(0.15)
        iconContainer.layer.cornerRadius = 20
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iconContainer)

        let iconImageView = UIImageView()
        if name.contains("Quiz") {
            iconImageView.image = UIImage(systemName: "questionmark")
        } else if name.contains("Connections") {
            iconImageView.image = UIImage(systemName: "puzzlepiece")
        } else if name.contains("Catcher") {
            iconImageView.image = UIImage(systemName: "arrow.down")
        } else {
            iconImageView.image = UIImage(systemName: "gamecontroller")
        }
        iconImageView.tintColor = accentColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImageView)

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameLabel)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        let dateString = dateFormatter.string(from: date)

        let dateLabel = UILabel()
        dateLabel.text = dateString
        dateLabel.font = UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .darkGray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(dateLabel)

        let scoreLabel = UILabel()
        scoreLabel.text = "\(score) pts"
        scoreLabel.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        scoreLabel.textColor = accentColor
        scoreLabel.textAlignment = .right
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(scoreLabel)

        NSLayoutConstraint.activate([
             container.heightAnchor.constraint(equalToConstant: 70),

            iconContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            nameLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: scoreLabel.leadingAnchor, constant: -8),

            dateLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: scoreLabel.leadingAnchor, constant: -8),

            scoreLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            scoreLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            scoreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])

        return container
    }
}