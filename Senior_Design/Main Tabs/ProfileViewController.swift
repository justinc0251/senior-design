import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private var profileImageView: UIImageView!
    private var nameLabel: UILabel!
    private var usernameLabel: UILabel!
    private var joinDateLabel: UILabel!
    
    private var statsContainerView: UIView!
    private var friendsContainer: UIView!
    private var pointsContainer: UIView!
    
    private var addFriendsButton: UIButton!
    private var shareButton: UIButton!
    
    // Recent Activity Properties
    private var activityContainerView: UIView!
    private var activityTitleLabel: UILabel!
    private var noActivityLabel: UILabel!
    private var activityStackView: UIStackView!
    private var recentGames: [(name: String, date: Date, score: Int)] = []
    
    private let accentColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
    private let secondaryColor = UIColor(red: 87/255, green: 155/255, blue: 252/255, alpha: 1.0)
    
    private var currentUserId: String?
    private var userData: [String: Any]?
    private var followingCount: Int = 0
    private var followersCount: Int = 0
    
    private var friendRequestsButton: UIBarButtonItem!
    private var friendRequestBadge: UIView?
    private var hasPendingRequests: Bool = false
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        setupUI()
        fetchUserData()
        fetchRecentGames()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserData()
        checkPendingFriendRequests()
        fetchRecentGames() // Refresh recent games when view appears
    }
    
    // MARK: - Data Fetching
    private func fetchUserData() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Error: No authenticated user found")
            return
        }
        
        let userId = currentUser.uid
        currentUserId = userId
        let db = Firestore.firestore()
            
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data() else {
                print("Error fetching user data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.userData = data
            
            DispatchQueue.main.async {
                self.updateUIWithUserData()
            }
        }
        
        db.collection("friendRequests")
        .whereField("fromUserId", isEqualTo: userId)
        .whereField("status", isEqualTo: "accepted")
        .getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            self.followingCount = snapshot?.documents.count ?? 0
            
            DispatchQueue.main.async {
                if let titleLabel = self.friendsContainer.subviews.first(where: { $0 is UILabel }) as? UILabel {
                    titleLabel.text = "\(self.followingCount)"
                }
            }
        }
    
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data() else {
                print("Error fetching user score: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            let score = data["score"] as? Int ?? 0
            DispatchQueue.main.async {
                if let titleLabel = self.pointsContainer.subviews.first(where: { $0 is UILabel }) as? UILabel {
                    titleLabel.text = "\(score)"
                }
            }
        }
    }

    private func checkPendingFriendRequests() {
        guard let userId = currentUserId else { return }
        
        let db = Firestore.firestore()
        db.collection("friendRequests")
            .whereField("toUserId", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                let hasPending = (snapshot?.documents.count ?? 0) > 0
                
                DispatchQueue.main.async {
                    self.hasPendingRequests = hasPending
                    self.updateFriendRequestBadge()
                }
            }
    }

    private func fetchRecentGames() {
        GameHistoryManager.shared.fetchRecentGames { [weak self] games, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching recent games: \(error.localizedDescription)")
                return
            }
            
            if let games = games {
                self.recentGames = games
                
                DispatchQueue.main.async {
                    self.updateRecentGamesUI()
                }
            }
        }
    }

    private func updateRecentGamesUI() {
        // Clear existing game views
        activityStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if recentGames.isEmpty {
            noActivityLabel.isHidden = false
        } else {
            noActivityLabel.isHidden = true
            
            // Add game views
            for game in recentGames {
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
        
        // Game icon
        let iconContainer = UIView()
        iconContainer.backgroundColor = accentColor.withAlphaComponent(0.15)
        iconContainer.layer.cornerRadius = 20
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iconContainer)
        
        let iconImageView = UIImageView()
        // Choose icon based on game name
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
        
        // Game name
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont(name: "Sen-Regular", size: 16)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameLabel)
        
        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateString = dateFormatter.string(from: date)
        
        // Date label
        let dateLabel = UILabel()
        dateLabel.text = dateString
        dateLabel.font = UIFont(name: "Sen-Regular", size: 14)
        dateLabel.textColor = .darkGray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(dateLabel)
        
        // Score label
        let scoreLabel = UILabel()
        scoreLabel.text = "\(score) pts"
        scoreLabel.font = UIFont(name: "Sen-Regular", size: 16)
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

    private func updateFriendRequestBadge() {
        // Create a custom button with badge
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let envelopeImage = UIImage(systemName: "envelope", withConfiguration: buttonConfig)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(envelopeImage, for: .normal)
        button.tintColor = accentColor
        button.addTarget(self, action: #selector(handleViewFriendRequests), for: .touchUpInside)
        
        // Add or remove badge based on pending status
        if hasPendingRequests {
            // Create badge indicator
            let badgeSize: CGFloat = 12
            let badge = UIView(frame: CGRect(x: 18, y: 0, width: badgeSize, height: badgeSize))
            badge.backgroundColor = UIColor.red
            badge.layer.cornerRadius = badgeSize / 2
            
            // Add white border to make it pop against any background
            badge.layer.borderWidth = 1
            badge.layer.borderColor = UIColor.white.cgColor
            
            // Optional: Add animation when badge appears
            if friendRequestBadge == nil {
                badge.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                    badge.transform = .identity
                })
            }
            
            button.addSubview(badge)
            friendRequestBadge = badge
        } else {
            friendRequestBadge?.removeFromSuperview()
            friendRequestBadge = nil
        }
        
        // Create bar button item with the custom button
        let barButton = UIBarButtonItem(customView: button)
        
        // Update the navigation bar with the new items
        if let settingsButton = navigationItem.rightBarButtonItems?.first {
            navigationItem.rightBarButtonItems = [settingsButton, barButton]
        } else {
            navigationItem.rightBarButtonItems = [barButton]
        }
        
        // Store reference to the new button
        friendRequestsButton = barButton
    }

    private func updateUIWithUserData() {
        guard let userData = userData else { return }
        
        if let name = userData["name"] as? String {
            nameLabel.text = name
            
            if let initial = name.first, let avatarLabel = profileImageView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                avatarLabel.text = String(initial)
            }
        }
        
        if let username = userData["username"] as? String {
            usernameLabel.text = "@\(username)"
        }
        
        if let joinTimestamp = userData["createdAt"] as? Timestamp {
            let date = joinTimestamp.dateValue()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM yyyy"
            let joinDateString = dateFormatter.string(from: date)
            joinDateLabel.text = "• Joined \(joinDateString)"
        } else if let joinTime = userData["creationTime"] as? Double {
            // Handle join date stored as a timestamp value
            let date = Date(timeIntervalSince1970: joinTime)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM yyyy"
            let joinDateString = dateFormatter.string(from: date)
            joinDateLabel.text = "• Joined \(joinDateString)"
        } else {
            // If no timestamp is available, use current date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM yyyy"
            let joinDateString = dateFormatter.string(from: Date())
            joinDateLabel.text = "• Joined \(joinDateString)"
        }
    }
    
    // MARK: - UI Setup
    private func setupTheme() {
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(handleSettings)
        )
        settingsButton.tintColor = accentColor
        
        friendRequestsButton = UIBarButtonItem(
            image: UIImage(systemName: "envelope"),
            style: .plain,
            target: self,
            action: #selector(handleViewFriendRequests)
        )
        friendRequestsButton.tintColor = accentColor
        
        navigationItem.rightBarButtonItems = [settingsButton, friendRequestsButton]
        
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = accentColor
    }
    
    private func setupUI() {
        setupProfileHeader()
        setupStatsView()
        setupActionButtons()
        setupRecentActivity()
        setupConstraints()
    }
    
    private func setupProfileHeader() {
        profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.tintColor = .white
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = accentColor // Keep the green background
        profileImageView.layer.cornerRadius = 40
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        profileImageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        profileImageView.layer.shadowRadius = 8
        profileImageView.layer.shadowOpacity = 1
        view.addSubview(profileImageView)
        
        let avatarLabel = UILabel()
        avatarLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        avatarLabel.textColor = .white
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.addSubview(avatarLabel)
        
        NSLayoutConstraint.activate([
            avatarLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
        
        nameLabel = UILabel()
        nameLabel.text = "" 
        nameLabel.font = UIFont(name: "Sen-Regular", size: 28)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        usernameLabel = UILabel()
        usernameLabel.text = "" 
        usernameLabel.font = UIFont(name: "Sen-Regular", size: 16)
        usernameLabel.textColor = .darkGray
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameLabel)
        
        joinDateLabel = UILabel()
        joinDateLabel.text = "" 
        joinDateLabel.font = UIFont(name: "Sen-Regular", size: 16)
        joinDateLabel.textColor = .darkGray
        joinDateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(joinDateLabel)
        
        nameLabel.text = "Loading..."
        usernameLabel.text = "@..."
        joinDateLabel.text = "• Joined ..."
    }

     private func setupRecentActivity() {
        // Container view
        activityContainerView = UIView()
        activityContainerView.backgroundColor = .white
        activityContainerView.layer.cornerRadius = 16
        activityContainerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        activityContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        activityContainerView.layer.shadowRadius = 8
        activityContainerView.layer.shadowOpacity = 1
        activityContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityContainerView)
        
        // Title label
        activityTitleLabel = UILabel()
        activityTitleLabel.text = "Recent Activity"
        activityTitleLabel.font = UIFont(name: "Sen-Regular", size: 18)
        activityTitleLabel.textColor = .black
        activityTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        activityContainerView.addSubview(activityTitleLabel)
        
        // No activity label (shown when there are no games)
        noActivityLabel = UILabel()
        noActivityLabel.text = "No recent games played"
        noActivityLabel.font = UIFont(name: "Sen-Regular", size: 16)
        noActivityLabel.textColor = .darkGray
        noActivityLabel.textAlignment = .center
        noActivityLabel.translatesAutoresizingMaskIntoConstraints = false
        activityContainerView.addSubview(noActivityLabel)
        
        // Stack view for game items
        activityStackView = UIStackView()
        activityStackView.axis = .vertical
        activityStackView.spacing = 12
        activityStackView.distribution = .fillEqually
        activityStackView.translatesAutoresizingMaskIntoConstraints = false
        activityContainerView.addSubview(activityStackView)
        
        NSLayoutConstraint.activate([
            activityTitleLabel.topAnchor.constraint(equalTo: activityContainerView.topAnchor, constant: 16),
            activityTitleLabel.leadingAnchor.constraint(equalTo: activityContainerView.leadingAnchor, constant: 16),
            
            noActivityLabel.centerXAnchor.constraint(equalTo: activityContainerView.centerXAnchor),
            noActivityLabel.centerYAnchor.constraint(equalTo: activityContainerView.centerYAnchor),
            
            activityStackView.topAnchor.constraint(equalTo: activityTitleLabel.bottomAnchor, constant: 16),
            activityStackView.leadingAnchor.constraint(equalTo: activityContainerView.leadingAnchor, constant: 16),
            activityStackView.trailingAnchor.constraint(equalTo: activityContainerView.trailingAnchor, constant: -16),
            activityStackView.bottomAnchor.constraint(equalTo: activityContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupStatsView() {
        statsContainerView = UIView()
        statsContainerView.backgroundColor = .white
        statsContainerView.layer.cornerRadius = 16
        statsContainerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        statsContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        statsContainerView.layer.shadowRadius = 8
        statsContainerView.layer.shadowOpacity = 1
        statsContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statsContainerView)
        
        friendsContainer = createStatContainer(title: "0", subtitle: "Friends")
        statsContainerView.addSubview(friendsContainer)

        let friendsTapGesture = UITapGestureRecognizer(target: self, action: #selector(friendsTapped))
        friendsContainer.addGestureRecognizer(friendsTapGesture)
        friendsContainer.isUserInteractionEnabled = true
        
        let separator = UIView()
        separator.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        separator.translatesAutoresizingMaskIntoConstraints = false
        statsContainerView.addSubview(separator)
        
        pointsContainer = createStatContainer(title: "0", subtitle: "Points")
        statsContainerView.addSubview(pointsContainer)
        
        
        NSLayoutConstraint.activate([
            friendsContainer.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor),
            friendsContainer.topAnchor.constraint(equalTo: statsContainerView.topAnchor),
            friendsContainer.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor),
            friendsContainer.widthAnchor.constraint(equalTo: statsContainerView.widthAnchor, multiplier: 0.5),
            
            separator.centerXAnchor.constraint(equalTo: statsContainerView.centerXAnchor),
            separator.topAnchor.constraint(equalTo: statsContainerView.topAnchor, constant: 15),
            separator.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: -15),
            separator.widthAnchor.constraint(equalToConstant: 1),
            
            pointsContainer.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor),
            pointsContainer.topAnchor.constraint(equalTo: statsContainerView.topAnchor),
            pointsContainer.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor),
            pointsContainer.widthAnchor.constraint(equalTo: statsContainerView.widthAnchor, multiplier: 0.5),
        ])
    }
    
    private func createStatContainer(title: String, subtitle: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont(name: "Sen-Regular", size: 24)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont(name: "Sen-Regular", size: 16)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5)
        ])
        
        return container
    }
    
    private func setupActionButtons() {
        addFriendsButton = UIButton(type: .system)
        addFriendsButton.setTitle("ADD FRIENDS", for: .normal)
        addFriendsButton.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
        addFriendsButton.tintColor = .white
        addFriendsButton.titleLabel?.font = UIFont(name: "Sen-Regular", size: 16)
        addFriendsButton.backgroundColor = secondaryColor
        addFriendsButton.layer.cornerRadius = 16
        addFriendsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        addFriendsButton.addTarget(self, action: #selector(handleAddFriends), for: .touchUpInside)
        addFriendsButton.translatesAutoresizingMaskIntoConstraints = false
        addFriendsButton.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        addFriendsButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addFriendsButton.layer.shadowRadius = 4
        addFriendsButton.layer.shadowOpacity = 1
        view.addSubview(addFriendsButton)
        
        shareButton = UIButton(type: .system)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .white
        shareButton.backgroundColor = accentColor
        shareButton.layer.cornerRadius = 16
        shareButton.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        shareButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        shareButton.layer.shadowRadius = 4
        shareButton.layer.shadowOpacity = 1
        view.addSubview(shareButton)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            profileImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            
            joinDateLabel.leadingAnchor.constraint(equalTo: usernameLabel.trailingAnchor, constant: 5),
            joinDateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            
            statsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statsContainerView.topAnchor.constraint(equalTo: joinDateLabel.bottomAnchor, constant: 20),
            statsContainerView.heightAnchor.constraint(equalToConstant: 70),
            
            addFriendsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addFriendsButton.topAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: 20),
            addFriendsButton.heightAnchor.constraint(equalToConstant: 50),
            addFriendsButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            
            shareButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            shareButton.topAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: 20),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            activityContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            activityContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            activityContainerView.topAnchor.constraint(equalTo: addFriendsButton.bottomAnchor, constant: 20),
            activityContainerView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            activityContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150)
        ])
    }
    
    // MARK: - Actions
    @objc private func friendsTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let friendsVC = FriendsListViewController()
        friendsVC.accentColor = secondaryColor
        navigationController?.pushViewController(friendsVC, animated: true)
    }

    @objc private func handleSettings() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let alertController = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
        
        let editProfileAction = UIAlertAction(title: "Edit Profile", style: .default) { _ in
            self.handleEditProfile()
        }
        
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
            self.handleLogout()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(editProfileAction)
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    @objc private func handleEditProfile() {
        let alertController = UIAlertController(title: "Edit Profile", message: nil, preferredStyle: .alert)
        
        let currentName = nameLabel.text ?? ""
        let currentUsername = usernameLabel.text?.replacingOccurrences(of: "@", with: "") ?? ""
        
        alertController.addTextField { textField in
            textField.placeholder = "Name"
            textField.text = currentName
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Username"
            textField.text = currentUsername
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                let userId = self.currentUserId,
                let nameTextField = alertController.textFields?[0],
                let usernameTextField = alertController.textFields?[1],
                let newName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                let newUsername = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                !newName.isEmpty, !newUsername.isEmpty else {
                self?.showAlert(title: "Error", message: "Name and username cannot be empty")
                return
            }
            
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userId)
            
            let updates: [String: Any] = [
                "name": newName,
                "username": newUsername
            ]
            
            userRef.updateData(updates) { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    self.showAlert(title: "Error", message: "Failed to update profile: \(error.localizedDescription)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.nameLabel.text = newName
                    self.usernameLabel.text = "@\(newUsername)"
                    
                    if let initial = newName.first, 
                    let avatarLabel = self.profileImageView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                        avatarLabel.text = String(initial)
                    }
                    
                    self.userData?["name"] = newName
                    self.userData?["username"] = newUsername
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        UserDefaults.standard.set(newName, forKey: "apple_user_name_\(uid)")
                    }
                    
                    self.showToast(message: "Profile updated successfully!")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showToast(message: String) {
        let toastView = UIView()
        toastView.backgroundColor = accentColor
        toastView.alpha = 0
        toastView.layer.cornerRadius = 8
        toastView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastView)
        
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = UIFont(name: "Sen-Regular", size: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        toastView.addSubview(label)
        
        NSLayoutConstraint.activate([
            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            toastView.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            toastView.heightAnchor.constraint(equalToConstant: 44),
            
            label.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: toastView.centerYAnchor)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toastView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
                toastView.alpha = 0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        })
    }
    
    @objc private func handleLogout() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
                UserDefaults.standard.set(false, forKey: "isLoggedIn")
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    let loginVC = LoginViewController()
                    let nav = UINavigationController(rootViewController: loginVC)
                    sceneDelegate.window?.rootViewController = nav
                }
            } catch {
                self.showAlert(title: "Error", message: "Failed to log out: \(error.localizedDescription)")
            }
        })
        
        present(alert, animated: true)
    }
    
    @objc private func handleAddFriends() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let searchVC = UserSearchViewController()
        searchVC.accentColor = secondaryColor
        let nav = UINavigationController(rootViewController: searchVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    @objc private func handleViewFriendRequests() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let requestsVC = FriendRequestsViewController()
        requestsVC.accentColor = secondaryColor
        navigationController?.pushViewController(requestsVC, animated: true)
    }
    
    @objc private func handleShare() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Get user stats - FIX: Cast to UILabel before accessing text property
        let score = (pointsContainer.subviews.first(where: { $0 is UILabel }) as? UILabel)?.text ?? "0"
        let friendCount = (friendsContainer.subviews.first(where: { $0 is UILabel }) as? UILabel)?.text ?? "0"
        let username = usernameLabel.text?.replacingOccurrences(of: "@", with: "") ?? "user"
        
        // Generate achievement message
        let recentGamesCount = recentGames.count
        let hasPlayedGames = recentGamesCount > 0
        
        // Create the sharing message
        var shareText = "I've earned \(score) points in Literr-acy! "
        
        if hasPlayedGames {
            shareText += "I've played \(recentGamesCount) games recently"
            
            // Add most recent game info if available
            if let mostRecent = recentGames.first {
                shareText += " and scored \(mostRecent.score) points in \(mostRecent.name)!"
            } else {
                shareText += "!"
            }
        } else {
            shareText += "Join me to start your waste sorting journey!"
        }
        
        // Add app link - replace with your actual App Store link when available
        shareText += "\n\nDownload Litter-acy and add me as a friend: @\(username)"
        
        // Generate a shareable image representing user stats
        let statsImage = generateShareableStatsImage()
        
        // Share both text and image
        let items: [Any] = [shareText, statsImage]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityController, animated: true)
    }

    // Generate a shareable image with user stats
    private func generateShareableStatsImage() -> UIImage {
        let imageSize = CGSize(width: 600, height: 400)
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        let image = renderer.image { context in
            // Background
            let rectangle = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(rectangle)
            
            // Add app name/logo at top
            let appName = "Litter-acy"
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: accentColor
            ]
            let headerSize = appName.size(withAttributes: headerAttributes)
            appName.draw(at: CGPoint(x: (imageSize.width - headerSize.width) / 2, y: 30), 
                        withAttributes: headerAttributes)
            
            // Add user name
            let userName = nameLabel.text ?? "User"
            let nameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .medium),
                .foregroundColor: UIColor.black
            ]
            userName.draw(at: CGPoint(x: 40, y: 90), withAttributes: nameAttributes)
            
            // Add horizontal line
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 40, y: 130))
            path.addLine(to: CGPoint(x: imageSize.width - 40, y: 130))
            UIColor.lightGray.setStroke()
            path.lineWidth = 1
            path.stroke()
            
            // Add stats
            let score = (pointsContainer.subviews.first(where: { $0 is UILabel }) as? UILabel)?.text ?? "0"
            let friendCount = (friendsContainer.subviews.first(where: { $0 is UILabel }) as? UILabel)?.text ?? "0"
            
            let statsText = "Score: \(score) points\nFriends: \(friendCount)"
            let statsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24),
                .foregroundColor: UIColor.darkGray
            ]
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            
            let statsAttributedText = NSAttributedString(
                string: statsText,
                attributes: statsAttributes
            )
            
            statsAttributedText.draw(in: CGRect(x: 40, y: 150, width: imageSize.width - 80, height: 100))
            
            // Add recent games if any
            if !recentGames.isEmpty {
                let recentTitle = "Recent Activity"
                let recentAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 20, weight: .medium),
                    .foregroundColor: UIColor.black
                ]
                recentTitle.draw(at: CGPoint(x: 40, y: 260), withAttributes: recentAttributes)
                
                // Show up to 2 recent games
                let gamesToShow = min(recentGames.count, 2)
                for i in 0..<gamesToShow {
                    let game = recentGames[i]
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM d, yyyy"
                    
                    let gameText = "• \(game.name) - \(game.score) points (\(dateFormatter.string(from: game.date)))"
                    let gameAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 18),
                        .foregroundColor: UIColor.darkGray
                    ]
                    
                    gameText.draw(at: CGPoint(x: 50, y: 300 + (i * 30)), withAttributes: gameAttributes)
                }
            }
        }
        
        return image
    }
}
