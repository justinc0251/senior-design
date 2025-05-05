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

    // MARK: - Recent Activity Properties
    private var activityContainerView: UIView!
    private var activityTitleLabel: UILabel!
    private var noActivityLabel: UILabel!
    private var activityStackView: UIStackView!
    private var recentGames: [(name: String, date: Date, score: Int)] = []

    private let accentColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
    private let secondaryColor = UIColor(red: 87/255, green: 155/255, blue: 252/255, alpha: 1.0)

    private var userData: [String: Any]?
    private var followingCount: Int = 0

    private var friendRequestsButton: UIBarButtonItem!
    private var settingsButton: UIBarButtonItem!
    private var friendRequestBadge: UIView?
    private var hasPendingRequests: Bool = false

    private var loginPromptButton: UIButton?

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIStructure()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkAuthStatusAndUpdateUI()
    }

    // MARK: - Auth Status Check & UI Update
    private func checkAuthStatusAndUpdateUI() {
        print("Checking Auth Status...")
        if AuthManager.shared.isGuest {
            print("User is Guest.")
            configureUIForGuest()

        } else if AuthManager.shared.isLoggedIn {
            print("User is Logged In.")
            configureUIForLoggedInUser()
            fetchUserData()
            fetchRecentGames()
            checkPendingFriendRequests()

        } else {
             print("Error: Profile screen reached in invalid auth state (neither guest nor logged in). Navigating to login.")
             (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.navigateToLogin()
        }
    }

    private func configureUIForGuest() {
        nameLabel.text = "Guest User"
        usernameLabel.text = "@guest"
        joinDateLabel.text = ""
        profileImageView.backgroundColor = .systemGray
        if let avatarLabel = profileImageView.subviews.first(where: { $0 is UILabel }) as? UILabel {
            avatarLabel.text = "G"
        }

        statsContainerView.isHidden = true
        addFriendsButton.isHidden = true
        shareButton.isHidden = true
        activityContainerView.isHidden = true

        navigationItem.rightBarButtonItems = []

        showLoginPrompt()
    }

    private func configureUIForLoggedInUser() {
        statsContainerView.isHidden = false
        addFriendsButton.isHidden = false
        shareButton.isHidden = false
        activityContainerView.isHidden = false

        profileImageView.backgroundColor = accentColor

        setupNavigationBarItems()

        hideLoginPrompt()

        nameLabel.text = "Loading..."
        usernameLabel.text = "@..."
        joinDateLabel.text = "• Joined ..."
        if let avatarLabel = profileImageView.subviews.first(where: { $0 is UILabel }) as? UILabel {
             avatarLabel.text = "?"
        }
        if let friendsTitleLabel = friendsContainer.subviews.first(where: { $0 is UILabel }) as? UILabel {
             friendsTitleLabel.text = "0"
        }
         if let pointsTitleLabel = pointsContainer.subviews.first(where: { $0 is UILabel }) as? UILabel {
             pointsTitleLabel.text = "0"
         }
    }


    // MARK: - Data Fetching (Guarded)
    private func fetchUserData() {
        guard AuthManager.shared.isLoggedIn, let userId = AuthManager.shared.currentUserId else {
            print("ProfileVC: Not logged in, skipping user data fetch.")
            return
        }
        print("ProfileVC: Fetching user data for \(userId)")

        let db = Firestore.firestore()

        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                 print("Error fetching user document: \(error.localizedDescription)")
                 self.nameLabel.text = "Error"
                 self.usernameLabel.text = ""
                 self.joinDateLabel.text = ""
                 return
            }

            guard let data = snapshot?.data() else {
                print("Error: User document data not found.")
                 self.nameLabel.text = "User Not Found"
                 self.usernameLabel.text = ""
                 self.joinDateLabel.text = ""
                return
            }

            self.userData = data

            DispatchQueue.main.async {
                self.updateUIWithUserData(data: data)
            }
        }

        db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: userId)
            .whereField("status", isEqualTo: "accepted")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching following count: \(error.localizedDescription)")
                    return
                }
                self.followingCount = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    if let titleLabel = self.friendsContainer.subviews.first(where: { $0 is UILabel }) as? UILabel {
                        titleLabel.text = "\(self.followingCount)"
                    }
                }
            }
    }

    private func checkPendingFriendRequests() {
         guard AuthManager.shared.isLoggedIn, let userId = AuthManager.shared.currentUserId else {
             self.hasPendingRequests = false
             self.updateFriendRequestBadge()
             print("ProfileVC: Not logged in, skipping friend request check.")
             return
         }
        print("ProfileVC: Checking pending friend requests for \(userId)")

        let db = Firestore.firestore()
        db.collection("friendRequests")
            .whereField("toUserId", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error checking pending friend requests: \(error.localizedDescription)")
                    self.hasPendingRequests = false
                } else {
                    let hasPending = (snapshot?.documents.count ?? 0) > 0
                     print("ProfileVC: Pending requests found: \(hasPending)")
                    self.hasPendingRequests = hasPending
                }

                DispatchQueue.main.async {
                    self.updateFriendRequestBadge()
                }
            }
    }

    private func fetchRecentGames() {
         guard AuthManager.shared.isLoggedIn else {
             print("ProfileVC: Guest user, skipping recent games fetch.")
             self.recentGames = []
             self.updateRecentGamesUI()
             return
         }
         print("ProfileVC: Fetching recent games...")

        GameHistoryManager.shared.fetchRecentGames { [weak self] games, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching recent games: \(error.localizedDescription)")
                self.recentGames = []
            } else {
                self.recentGames = games ?? []
            }

            DispatchQueue.main.async {
                self.updateRecentGamesUI()
            }
        }
    }

     private func updateUIWithUserData(data: [String: Any]) {
         if let name = data["name"] as? String {
             nameLabel.text = name
             if let initial = name.first, let avatarLabel = profileImageView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                 avatarLabel.text = String(initial).uppercased()
             }
         } else {
             nameLabel.text = "User"
              if let avatarLabel = profileImageView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                   avatarLabel.text = "U"
               }
         }

         if let username = data["username"] as? String {
             usernameLabel.text = "@\(username)"
         } else {
             usernameLabel.text = "@username"
         }

         var joinDateString = "Date unknown"
         if let joinTimestamp = data["createdAt"] as? Timestamp {
             let date = joinTimestamp.dateValue()
             joinDateString = formatDate(date)
         } else if let joinTime = data["creationTime"] as? Double {
             let date = Date(timeIntervalSince1970: joinTime)
             joinDateString = formatDate(date)
         }
         joinDateLabel.text = "• Joined \(joinDateString)"

         let score = data["score"] as? Int ?? 0
         if let titleLabel = self.pointsContainer.subviews.first(where: { $0 is UILabel }) as? UILabel {
             titleLabel.text = "\(score)"
         }
     }

     private func formatDate(_ date: Date) -> String {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "MMM d, yyyy"
         return dateFormatter.string(from: date)
     }

    private func updateRecentGamesUI() {
        activityStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let isLoggedIn = AuthManager.shared.isLoggedIn
        let shouldShowActivity = isLoggedIn && !recentGames.isEmpty

        activityStackView.isHidden = !shouldShowActivity
        noActivityLabel.isHidden = shouldShowActivity

        if isLoggedIn && recentGames.isEmpty {
             noActivityLabel.text = "No recent games played"
        } else if !isLoggedIn {
             noActivityLabel.text = "Log in to see activity"
        }

        if shouldShowActivity {
            let gamesToShow = recentGames.prefix(3)
            for game in gamesToShow {
                let gameView = createGameView(name: game.name, date: game.date, score: game.score)
                activityStackView.addArrangedSubview(gameView)
            }
        }
        activityContainerView.isHidden = !isLoggedIn
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
        if name.lowercased().contains("trivia") || name.lowercased().contains("quiz") {
             iconImageView.image = UIImage(systemName: "questionmark")
         } else if name.lowercased().contains("connections") {
             iconImageView.image = UIImage(systemName: "puzzlepiece")
         } else if name.lowercased().contains("catcher") {
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
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateString = dateFormatter.string(from: date)

        let dateLabel = UILabel()
        dateLabel.text = dateString
        dateLabel.font = UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .darkGray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(dateLabel)

        let scoreLabel = UILabel()
        scoreLabel.text = "\(score) pts"
        scoreLabel.font = UIFont(name: "Sen-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
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

            scoreLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            scoreLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            scoreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),

            nameLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: scoreLabel.leadingAnchor, constant: -8),

            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])

        return container
    }

    private func updateFriendRequestBadge() {
        guard AuthManager.shared.isLoggedIn else {
             friendRequestBadge?.removeFromSuperview()
             friendRequestBadge = nil
              if let button = friendRequestsButton?.customView as? UIButton {
                  button.subviews.forEach { if $0.backgroundColor == .red { $0.removeFromSuperview() } }
              }
            return
        }

        guard let button = friendRequestsButton?.customView as? UIButton else {
            print("Warning: friendRequestsButton customView is not setup correctly.")
            setupNavigationBarItems()
            guard let newButton = friendRequestsButton?.customView as? UIButton else { return }
            configureBadge(on: newButton)
            return
        }
         configureBadge(on: button)
    }

     private func configureBadge(on button: UIButton) {
          friendRequestBadge?.removeFromSuperview()
          friendRequestBadge = nil
          button.subviews.forEach { if $0.backgroundColor == .red { $0.removeFromSuperview() } }


         if hasPendingRequests {
             let badgeSize: CGFloat = 10
             let badge = UIView(frame: CGRect(x: button.frame.width - badgeSize - 2, y: 2, width: badgeSize, height: badgeSize))
             badge.backgroundColor = UIColor.red
             badge.layer.cornerRadius = badgeSize / 2
             badge.layer.borderWidth = 1
             badge.layer.borderColor = UIColor.white.cgColor
             badge.isUserInteractionEnabled = false

             badge.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
             button.addSubview(badge)
             friendRequestBadge = badge

             UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [], animations: {
                 badge.transform = .identity
             })
              print("Badge Added")
         } else {
              print("No pending requests, badge not added.")
         }
     }

    // MARK: - UI Setup Helpers
    private func setupUIStructure() {
         view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
         setupProfileHeader()
         setupStatsView()
         setupActionButtons()
         setupRecentActivity()
    }

    private func setupNavigationBarItems() {
        settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(handleSettings)
        )
        settingsButton.tintColor = accentColor

        let requestsButtonContainer = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let envelopeImage = UIImage(systemName: "envelope", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .regular))
        requestsButtonContainer.setImage(envelopeImage, for: .normal)
        requestsButtonContainer.tintColor = accentColor
        requestsButtonContainer.addTarget(self, action: #selector(handleViewFriendRequests), for: .touchUpInside)

        friendRequestsButton = UIBarButtonItem(customView: requestsButtonContainer)

        navigationItem.rightBarButtonItems = [settingsButton, friendRequestsButton]
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = accentColor
    }

    // MARK: - Profile Header Setup
    private func setupProfileHeader() {
        profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.tintColor = .white
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = accentColor
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
        avatarLabel.font = UIFont(name: "Sen-Bold", size: 30) ?? UIFont.systemFont(ofSize: 30, weight: .bold)
        avatarLabel.textColor = .white
        avatarLabel.textAlignment = .center
        avatarLabel.text = "?"
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.addSubview(avatarLabel)

        NSLayoutConstraint.activate([
            avatarLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])

        nameLabel = UILabel()
        nameLabel.text = "Loading..."
        nameLabel.font = UIFont(name: "Sen-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)

        usernameLabel = UILabel()
        usernameLabel.text = "@..."
        usernameLabel.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        usernameLabel.textColor = .darkGray
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameLabel)

        joinDateLabel = UILabel()
        joinDateLabel.text = "• Joined ..."
        joinDateLabel.font = UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        joinDateLabel.textColor = .darkGray
        joinDateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(joinDateLabel)
    }

    // MARK: - Recent Activity Setup
    private func setupRecentActivity() {
        activityContainerView = UIView()
        activityContainerView.backgroundColor = .white
        activityContainerView.layer.cornerRadius = 16
        activityContainerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        activityContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        activityContainerView.layer.shadowRadius = 8
        activityContainerView.layer.shadowOpacity = 1
        activityContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityContainerView)

        activityTitleLabel = UILabel()
        activityTitleLabel.text = "Recent Activity"
        activityTitleLabel.font = UIFont(name: "Sen-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        activityTitleLabel.textColor = .black
        activityTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        activityContainerView.addSubview(activityTitleLabel)

        let viewAllButton = UIButton(type: .system)
        viewAllButton.setTitle("View All", for: .normal)
        viewAllButton.titleLabel?.font = UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        viewAllButton.tintColor = accentColor
        viewAllButton.addTarget(self, action: #selector(handleViewAllActivity), for: .touchUpInside)
        viewAllButton.translatesAutoresizingMaskIntoConstraints = false
        activityContainerView.addSubview(viewAllButton)

        noActivityLabel = UILabel()
        noActivityLabel.text = "No recent games played"
        noActivityLabel.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        noActivityLabel.textColor = .darkGray
        noActivityLabel.textAlignment = .center
        noActivityLabel.isHidden = true
        noActivityLabel.translatesAutoresizingMaskIntoConstraints = false
        activityContainerView.addSubview(noActivityLabel)

        activityStackView = UIStackView()
        activityStackView.axis = .vertical
        activityStackView.spacing = 12
        activityStackView.distribution = .fill
        activityStackView.translatesAutoresizingMaskIntoConstraints = false
        activityContainerView.addSubview(activityStackView)

        NSLayoutConstraint.activate([
            activityTitleLabel.topAnchor.constraint(equalTo: activityContainerView.topAnchor, constant: 16),
            activityTitleLabel.leadingAnchor.constraint(equalTo: activityContainerView.leadingAnchor, constant: 16),

            viewAllButton.centerYAnchor.constraint(equalTo: activityTitleLabel.centerYAnchor),
            viewAllButton.trailingAnchor.constraint(equalTo: activityContainerView.trailingAnchor, constant: -16),

            noActivityLabel.topAnchor.constraint(equalTo: activityTitleLabel.bottomAnchor, constant: 20),
            noActivityLabel.leadingAnchor.constraint(equalTo: activityContainerView.leadingAnchor, constant: 16),
            noActivityLabel.trailingAnchor.constraint(equalTo: activityContainerView.trailingAnchor, constant: -16),
             noActivityLabel.bottomAnchor.constraint(lessThanOrEqualTo: activityContainerView.bottomAnchor, constant: -16),

            activityStackView.topAnchor.constraint(equalTo: activityTitleLabel.bottomAnchor, constant: 16),
            activityStackView.leadingAnchor.constraint(equalTo: activityContainerView.leadingAnchor, constant: 16),
            activityStackView.trailingAnchor.constraint(equalTo: activityContainerView.trailingAnchor, constant: -16),
            activityStackView.bottomAnchor.constraint(equalTo: activityContainerView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Stats View Setup
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
        titleLabel.font = UIFont(name: "Sen-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),

            subtitleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])
        return container
    }

    // MARK: - Action Buttons Setup
    private func setupActionButtons() {
        addFriendsButton = UIButton(type: .system)
        addFriendsButton.setTitle("ADD FRIENDS", for: .normal)
        addFriendsButton.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
        addFriendsButton.tintColor = .white
        addFriendsButton.titleLabel?.font = UIFont(name: "Sen-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        addFriendsButton.backgroundColor = secondaryColor
        addFriendsButton.layer.cornerRadius = 16
        addFriendsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        addFriendsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        addFriendsButton.addTarget(self, action: #selector(handleAddFriends), for: .touchUpInside)
        addFriendsButton.translatesAutoresizingMaskIntoConstraints = false
        addFriendsButton.layer.shadowColor = secondaryColor.withAlphaComponent(0.3).cgColor
        addFriendsButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addFriendsButton.layer.shadowRadius = 8
        addFriendsButton.layer.shadowOpacity = 1
        view.addSubview(addFriendsButton)

        shareButton = UIButton(type: .system)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .white
        shareButton.backgroundColor = accentColor
        shareButton.layer.cornerRadius = 16
        shareButton.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.layer.shadowColor = accentColor.withAlphaComponent(0.3).cgColor
        shareButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        shareButton.layer.shadowRadius = 8
        shareButton.layer.shadowOpacity = 1
        view.addSubview(shareButton)
    }

    // MARK: - Constraints Setup
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            profileImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: safeArea.trailingAnchor, constant: -20),

            usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),

            joinDateLabel.leadingAnchor.constraint(equalTo: usernameLabel.trailingAnchor, constant: 4),
            joinDateLabel.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
            joinDateLabel.trailingAnchor.constraint(lessThanOrEqualTo: safeArea.trailingAnchor, constant: -20),

            statsContainerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            statsContainerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            statsContainerView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 24),
            statsContainerView.heightAnchor.constraint(equalToConstant: 70),

            addFriendsButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            addFriendsButton.topAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: 20),
            addFriendsButton.heightAnchor.constraint(equalToConstant: 50),
            addFriendsButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),

            shareButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            shareButton.topAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: 20),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),

            activityContainerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            activityContainerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            activityContainerView.topAnchor.constraint(equalTo: addFriendsButton.bottomAnchor, constant: 20),
            activityContainerView.bottomAnchor.constraint(lessThanOrEqualTo: safeArea.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Guest Mode UI Helpers
    private func showLoginPrompt() {
         statsContainerView.isHidden = true
         addFriendsButton.isHidden = true
         shareButton.isHidden = true
         activityContainerView.isHidden = true
         navigationItem.rightBarButtonItems = []

        guard loginPromptButton == nil else { return }

        let prompt = UIButton(type: .system)
        prompt.setTitle("Log In or Sign Up", for: .normal)
        prompt.titleLabel?.font = UIFont(name: "Sen-Bold", size: 16)
        prompt.setTitleColor(.white, for: .normal)
        prompt.backgroundColor = accentColor
        prompt.layer.cornerRadius = 16
        prompt.addTarget(self, action: #selector(promptLoginTapped), for: .touchUpInside)
        prompt.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(prompt)

        NSLayoutConstraint.activate([
            prompt.topAnchor.constraint(equalTo: joinDateLabel.bottomAnchor, constant: 30),
            prompt.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            prompt.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            prompt.heightAnchor.constraint(equalToConstant: 50)
        ])
        loginPromptButton = prompt
        view.bringSubviewToFront(prompt)
    }

    private func hideLoginPrompt() {
        loginPromptButton?.removeFromSuperview()
        loginPromptButton = nil
    }

    @objc private func promptLoginTapped() {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.navigateToLogin()
    }

    // MARK: - Actions (Guarded)
    @objc private func friendsTapped() {
        guard !AuthManager.shared.isGuest else {
             showLoginRequiredAlert(feature: "viewing friends")
             return
        }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        let friendsVC = FriendsListViewController()
        friendsVC.accentColor = secondaryColor

        let nav = UINavigationController(rootViewController: friendsVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
             sheet.detents = [.large()]
             sheet.prefersGrabberVisible = true
             sheet.preferredCornerRadius = 24
        }
        present(nav, animated: true)
    }

    @objc private func handleViewAllActivity() {
        guard !AuthManager.shared.isGuest else {
             showLoginRequiredAlert(feature: "viewing game history")
             return
        }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        let gameHistoryVC = GameHistoryViewController()
        gameHistoryVC.accentColor = accentColor

        let nav = UINavigationController(rootViewController: gameHistoryVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
             sheet.detents = [.large()]
             sheet.prefersGrabberVisible = true
             sheet.preferredCornerRadius = 24
        }
        present(nav, animated: true)
    }


    @objc private func handleSettings() {
        guard !AuthManager.shared.isGuest else {
             showLoginRequiredAlert(feature: "accessing settings")
             return
        }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        let alertController = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)

        let editProfileAction = UIAlertAction(title: "Edit Profile", style: .default) { _ in
            self.handleEditProfile()
        }

        let deleteAccountAction = UIAlertAction(title: "Delete Account", style: .destructive) { _ in
            self.confirmAccountDeletion()
        }

        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
            self.handleLogout()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(editProfileAction)
        alertController.addAction(deleteAccountAction)
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)

        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItems?.first(where: { $0 == settingsButton })
        }

        present(alertController, animated: true, completion: nil)
    }

    private func confirmAccountDeletion() {
        guard !AuthManager.shared.isGuest else { return }

        let alert = UIAlertController(
            title: "Delete Account?",
            message: "This is irreversible. All your data, including profile, scores, friends, and game history, will be permanently deleted.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete Account", style: .destructive) { _ in
            self.initiateAccountDeletionProcess()
        })
        present(alert, animated: true)
    }

    private func initiateAccountDeletionProcess() {
         guard let user = Auth.auth().currentUser else {
             showAlert(title: "Error", message: "You must be logged in to delete your account.")
             return
         }
         let userId = user.uid
         let db = Firestore.firestore()

         let activityIndicator = UIActivityIndicatorView(style: .large)
         activityIndicator.center = view.center
         activityIndicator.color = accentColor
         activityIndicator.startAnimating()
         view.addSubview(activityIndicator)
         view.isUserInteractionEnabled = false

         let dispatchGroup = DispatchGroup()
         var deletionError: Error? = nil

         dispatchGroup.enter()
         db.collection("users").document(userId).delete { error in
             if let error = error { deletionError = deletionError ?? error }
             dispatchGroup.leave()
         }

         dispatchGroup.enter()
         deleteDocuments(in: db.collection("gameHistory").whereField("userId", isEqualTo: userId), group: dispatchGroup) { error in
             if let error = error { deletionError = deletionError ?? error }
         }

         dispatchGroup.enter()
         deleteDocuments(in: db.collection("friendRequests").whereField("fromUserId", isEqualTo: userId), group: dispatchGroup) { error in
             if let error = error { deletionError = deletionError ?? error }
         }

         dispatchGroup.enter()
         deleteDocuments(in: db.collection("friendRequests").whereField("toUserId", isEqualTo: userId), group: dispatchGroup) { error in
             if let error = error { deletionError = deletionError ?? error }
         }

         dispatchGroup.notify(queue: .main) {
             if let error = deletionError {
                  activityIndicator.removeFromSuperview()
                  self.view.isUserInteractionEnabled = true
                 self.showAlert(title: "Deletion Error", message: "Failed to delete all associated data: \(error.localizedDescription). Please try again.")
                 return
             }

             print("Firestore data cleanup successful. Proceeding to delete Auth user.")
             user.delete { [weak self] error in
                 guard let self = self else { return }

                 activityIndicator.removeFromSuperview()
                 self.view.isUserInteractionEnabled = true

                 if let error = error {
                     if let authError = error as NSError?, authError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                         self.showAlert(title: "Re-authentication Required", message: "Please log out and log back in again before deleting your account.")
                     } else {
                         print("Firebase Auth deletion error: \(error.localizedDescription)")
                         self.showAlert(title: "Deletion Error", message: "Failed to delete account authentication: \(error.localizedDescription). Associated data might have been cleared.")
                     }
                     return
                 }

                 print("Firebase Auth user deleted successfully.")
                 AuthManager.shared.logout()
                 (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.navigateToLogin()
             }
         }
    }

    private func deleteDocuments(in query: Query, group: DispatchGroup, completion: @escaping (Error?) -> Void) {
         query.getDocuments { (snapshot, error) in
             defer { group.leave() }

             guard let snapshot = snapshot else {
                 print("Error fetching documents for deletion: \(error?.localizedDescription ?? "Unknown error")")
                 completion(error)
                 return
             }

             if snapshot.isEmpty {
                 print("No documents found matching query, nothing to delete.")
                 completion(nil)
                 return
             }

             let batch = Firestore.firestore().batch()
             snapshot.documents.forEach { batch.deleteDocument($0.reference) }

             batch.commit { err in
                 if let err = err {
                     print("Batch deletion failed: \(err.localizedDescription)")
                     completion(err)
                 } else {
                     print("Successfully batch deleted \(snapshot.documents.count) documents.")
                     completion(nil)
                 }
             }
         }
    }

    @objc private func handleEditProfile() {
        guard !AuthManager.shared.isGuest else {
             showLoginRequiredAlert(feature: "editing your profile")
             return
        }

        let editProfileVC = EditProfileViewController()
        editProfileVC.modalPresentationStyle = .pageSheet
        editProfileVC.delegate = self
        editProfileVC.currentName = nameLabel.text ?? ""
        editProfileVC.currentUsername = usernameLabel.text?.replacingOccurrences(of: "@", with: "") ?? ""
        editProfileVC.accentColor = accentColor

        if let sheet = editProfileVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.preferredCornerRadius = 24
            sheet.prefersGrabberVisible = true
        }

        present(editProfileVC, animated: true)
    }

    private func updateUserProfile(userId: String, newName: String, newUsername: String) {
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
                     avatarLabel.text = String(initial).uppercased()
                 }

                 self.userData?["name"] = newName
                 self.userData?["username"] = newUsername

                  if AuthManager.shared.isLoggedIn, let uid = AuthManager.shared.currentUserId {
                      UserDefaults.standard.set(newName, forKey: "apple_user_name_\(uid)")
                  }

                 self.showToast(message: "Profile updated successfully!")
             }
         }
    }

    private func showToast(message: String) {
         let toastView = UIView()
         toastView.backgroundColor = accentColor.withAlphaComponent(0.9)
         toastView.alpha = 0
         toastView.layer.cornerRadius = 8
         toastView.translatesAutoresizingMaskIntoConstraints = false
         guard let window = view.window else { return }
         window.addSubview(toastView)

         let label = UILabel()
         label.text = message
         label.textColor = .white
         label.font = UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
         label.textAlignment = .center
         label.numberOfLines = 0
         label.translatesAutoresizingMaskIntoConstraints = false
         toastView.addSubview(label)

         NSLayoutConstraint.activate([
             toastView.leadingAnchor.constraint(greaterThanOrEqualTo: window.leadingAnchor, constant: 20),
             toastView.trailingAnchor.constraint(lessThanOrEqualTo: window.trailingAnchor, constant: -20),
             toastView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
             toastView.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -30),
             toastView.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
             toastView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),

             label.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 16),
             label.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -16),
             label.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 12),
             label.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -12)
         ])

         UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
             toastView.alpha = 1
             toastView.transform = .identity
         }, completion: { _ in
             UIView.animate(withDuration: 0.4, delay: 2.5, options: .curveEaseIn, animations: {
                 toastView.alpha = 0
                 toastView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
             }, completion: { _ in
                 toastView.removeFromSuperview()
             })
         })
    }


    @objc private func handleLogout() {
        guard !AuthManager.shared.isGuest else { return }

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            AuthManager.shared.logout()
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.navigateToLogin()
        })

        present(alert, animated: true)
    }

    @objc private func handleAddFriends() {
        guard !AuthManager.shared.isGuest else {
             showLoginRequiredAlert(feature: "adding friends")
             return
        }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        let searchVC = UserSearchViewController()
        searchVC.accentColor = secondaryColor
        let nav = UINavigationController(rootViewController: searchVC)
        nav.modalPresentationStyle = .formSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        present(nav, animated: true)
    }

    @objc private func handleViewFriendRequests() {
         guard !AuthManager.shared.isGuest else {
              showLoginRequiredAlert(feature: "viewing friend requests")
              return
         }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        let requestsVC = FriendRequestsViewController()
        requestsVC.accentColor = secondaryColor
        navigationController?.pushViewController(requestsVC, animated: true)
    }

    @objc private func handleShare() {
        guard !AuthManager.shared.isGuest else {
             showLoginRequiredAlert(feature: "sharing your profile")
             return
        }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

         let score = (pointsContainer.subviews.first(where: { $0 is UILabel }) as? UILabel)?.text ?? "0"
         let friendCount = (friendsContainer.subviews.first(where: { $0 is UILabel }) as? UILabel)?.text ?? "0"
         let username = usernameLabel.text?.replacingOccurrences(of: "@", with: "") ?? "user"

         let recentGamesCount = recentGames.count
         let hasPlayedGames = recentGamesCount > 0

         var shareText = "I've earned \(score) points in Literr-acy! "

         if hasPlayedGames {
             shareText += "I've played \(recentGamesCount) games recently"
             if let mostRecent = recentGames.first {
                 shareText += " and scored \(mostRecent.score) points in \(mostRecent.name)!"
             } else {
                 shareText += "!"
             }
         } else {
             shareText += "Join me to start your waste sorting journey!"
         }

         shareText += "\n\nDownload Litter-acy and add me as a friend: @\(username)"

         let statsImage = generateShareableStatsImage()

         let items: [Any] = [shareText, statsImage]
         let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)

          if let popoverController = activityController.popoverPresentationController {
               popoverController.sourceView = shareButton
               popoverController.sourceRect = shareButton.bounds
               popoverController.permittedArrowDirections = .any
          }

         present(activityController, animated: true)
    }

    private func generateShareableStatsImage() -> UIImage {
         let imageSize = CGSize(width: 600, height: 400)
         let renderer = UIGraphicsImageRenderer(size: imageSize)

         let image = renderer.image { context in
             let rectangle = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
             context.cgContext.setFillColor(UIColor.white.cgColor)
             context.cgContext.fill(rectangle)

             let appName = "Litter-acy"
             let headerAttributes: [NSAttributedString.Key: Any] = [
                 .font: UIFont(name: "Sen-Bold", size: 36) ?? UIFont.systemFont(ofSize: 36, weight: .bold),
                 .foregroundColor: accentColor
             ]
             let headerSize = appName.size(withAttributes: headerAttributes)
             appName.draw(at: CGPoint(x: (imageSize.width - headerSize.width) / 2, y: 30),
                         withAttributes: headerAttributes)

             let userName = nameLabel.text ?? "User"
             let nameAttributes: [NSAttributedString.Key: Any] = [
                 .font: UIFont(name: "Sen-Regular", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .medium),
                 .foregroundColor: UIColor.black
             ]
             userName.draw(at: CGPoint(x: 40, y: 90), withAttributes: nameAttributes)

             let path = UIBezierPath()
             path.move(to: CGPoint(x: 40, y: 130))
             path.addLine(to: CGPoint(x: imageSize.width - 40, y: 130))
             UIColor.lightGray.setStroke()
             path.lineWidth = 1
             path.stroke()

             let score = (pointsContainer.subviews.first(where: { $0 is UILabel }) as? UILabel)?.text ?? "0"
             let friendCount = (friendsContainer.subviews.first(where: { $0 is UILabel }) as? UILabel)?.text ?? "0"

             let statsText = "Score: \(score) points\nFriends: \(friendCount)"
             let statsAttributes: [NSAttributedString.Key: Any] = [
                 .font: UIFont(name: "Sen-Regular", size: 24) ?? UIFont.systemFont(ofSize: 24),
                 .foregroundColor: UIColor.darkGray
             ]
             let paragraphStyle = NSMutableParagraphStyle()
             paragraphStyle.lineSpacing = 10
             let statsAttributedText = NSAttributedString(
                 string: statsText,
                 attributes: [.font: statsAttributes[.font]!, .foregroundColor: statsAttributes[.foregroundColor]!, .paragraphStyle: paragraphStyle]
             )
             statsAttributedText.draw(in: CGRect(x: 40, y: 150, width: imageSize.width - 80, height: 100))

             if !recentGames.isEmpty {
                 let recentTitle = "Recent Activity:"
                 let recentAttributes: [NSAttributedString.Key: Any] = [
                     .font: UIFont(name: "Sen-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold),
                     .foregroundColor: UIColor.black
                 ]
                 recentTitle.draw(at: CGPoint(x: 40, y: 260), withAttributes: recentAttributes)

                 let gamesToShow = min(recentGames.count, 2)
                 for i in 0..<gamesToShow {
                     let game = recentGames[i]
                     let dateFormatter = DateFormatter()
                     dateFormatter.dateFormat = "MMM d"

                     let gameText = "• \(game.name): \(game.score) pts (\(dateFormatter.string(from: game.date)))"
                     let gameAttributes: [NSAttributedString.Key: Any] = [
                         .font: UIFont(name: "Sen-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18),
                         .foregroundColor: UIColor.darkGray
                     ]
                     gameText.draw(at: CGPoint(x: 50, y: 300 + CGFloat(i * 28)), withAttributes: gameAttributes)
                 }
             } else {
                  let noActivityText = "Play some games to see activity!"
                  let noActivityAttributes: [NSAttributedString.Key: Any] = [
                      .font: UIFont(name: "Sen-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18),
                      .foregroundColor: UIColor.lightGray
                  ]
                   noActivityText.draw(at: CGPoint(x: 40, y: 270), withAttributes: noActivityAttributes)
             }

             let footerText = "Join me on Litter-acy!"
              let footerAttributes: [NSAttributedString.Key: Any] = [
                  .font: UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14),
                  .foregroundColor: UIColor.gray
              ]
              let footerSize = footerText.size(withAttributes: footerAttributes)
              footerText.draw(at: CGPoint(x: (imageSize.width - footerSize.width) / 2, y: imageSize.height - 40), withAttributes: footerAttributes)

         }
         return image
    }

    // MARK: - Alert Helper
    private func showAlert(title: String, message: String) {
         let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
         alertController.addAction(UIAlertAction(title: "OK", style: .default))
         DispatchQueue.main.async {
              self.present(alertController, animated: true)
         }
    }

     private func showLoginRequiredAlert(feature: String) {
         let alert = UIAlertController(
             title: "Login Required",
             message: "Please log in or sign up to \(feature).",
             preferredStyle: .alert
         )
         alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
         alert.addAction(UIAlertAction(title: "Log In / Sign Up", style: .default) { _ in
             (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.navigateToLogin()
         })
         present(alert, animated: true, completion: nil)
     }
}

// MARK: - EditProfileViewControllerDelegate
extension ProfileViewController: EditProfileViewControllerDelegate {
    func editProfileViewController(_ controller: EditProfileViewController, didUpdateProfileWithName name: String, username: String) {
        if let userId = AuthManager.shared.currentUserId {
            updateUserProfile(userId: userId, newName: name, newUsername: username)
        } else {
             print("Error: Cannot update profile, user ID not found after edit.")
        }
    }
}


// MARK: - EditProfileViewController
protocol EditProfileViewControllerDelegate: AnyObject {
    func editProfileViewController(_ controller: EditProfileViewController, didUpdateProfileWithName name: String, username: String)
}

class EditProfileViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
    weak var delegate: EditProfileViewControllerDelegate?
    var currentName: String = ""
    var currentUsername: String = ""
    var accentColor: UIColor = .systemBlue

    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let nameTextField = UITextField()
    private let usernameTextField = UITextField()
    private let saveButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground

        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)

        titleLabel.text = "Edit Profile"
        titleLabel.font = UIFont(name: "Sen-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        setupTextField(nameTextField, placeholder: "Full Name", text: currentName, icon: "person.fill")
        nameTextField.textContentType = .name
        nameTextField.autocapitalizationType = .words
        nameTextField.returnKeyType = .next
        nameTextField.delegate = self
        contentView.addSubview(nameTextField)

        setupTextField(usernameTextField, placeholder: "Username", text: currentUsername, icon: "at")
        usernameTextField.textContentType = .username
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
        usernameTextField.returnKeyType = .done
        usernameTextField.delegate = self
        contentView.addSubview(usernameTextField)

        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addSubview(activityIndicator)


        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.titleLabel?.font = UIFont(name: "Sen-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        saveButton.backgroundColor = accentColor
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.lightGray, for: .disabled)
        saveButton.layer.cornerRadius = 12
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        contentView.addSubview(saveButton)

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        cancelButton.setTitleColor(.secondaryLabel, for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        contentView.addSubview(cancelButton)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),

            usernameTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            usernameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            usernameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),

            saveButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            saveButton.heightAnchor.constraint(equalToConstant: 50),

             activityIndicator.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor),
             activityIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),

            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }

    private func setupTextField(_ textField: UITextField, placeholder: String, text: String, icon: String) {
        textField.backgroundColor = .systemGray6
        textField.placeholder = placeholder
        textField.text = text
        textField.layer.cornerRadius = 12
        textField.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        textField.textColor = .label
        textField.tintColor = accentColor
        textField.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .systemGray
        iconView.contentMode = .center
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 40))
        iconContainerView.addSubview(iconView)
        iconView.frame = CGRect(x: 15, y: 10, width: 20, height: 20)

        textField.leftView = iconContainerView
        textField.leftViewMode = .always

        textField.setRightPaddingPoints(10)
        textField.clearButtonMode = .whileEditing
    }

    // MARK: - Actions
    @objc private func handleSave() {
        view.endEditing(true)

        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty, !username.isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter both your name and username.")
            return
        }

        if username.contains(" ") || username.count < 3 {
             showAlert(title: "Invalid Username", message: "Username must be at least 3 characters long and contain no spaces.")
             return
        }

        if name == currentName && username == currentUsername {
            dismiss(animated: true)
            return
        }

        setLoading(true)

         if username.lowercased() != currentUsername.lowercased() {
             let db = Firestore.firestore()
             db.collection("users").whereField("username", isEqualTo: username).limit(to: 1).getDocuments { [weak self] (querySnapshot, error) in
                 guard let self = self else { return }

                 if let error = error {
                     self.setLoading(false)
                     self.showAlert(title: "Error", message: "Failed to check username availability: \(error.localizedDescription)")
                     return
                 }

                 if let snapshot = querySnapshot, !snapshot.isEmpty {
                      self.setLoading(false)
                     self.showAlert(title: "Username Taken", message: "The username '@\(username)' is already taken. Please choose a different one.")
                 } else {
                      self.setLoading(false)
                      self.dismiss(animated: true) {
                          self.delegate?.editProfileViewController(self, didUpdateProfileWithName: name, username: username)
                      }
                 }
             }
         } else {
              setLoading(false)
              dismiss(animated: true) {
                  self.delegate?.editProfileViewController(self, didUpdateProfileWithName: name, username: username)
              }
         }
    }

    private func setLoading(_ isLoading: Bool) {
         if isLoading {
             saveButton.isEnabled = false
             saveButton.setTitle("", for: .normal)
             activityIndicator.startAnimating()
         } else {
             saveButton.isEnabled = true
             saveButton.setTitle("Save Changes", for: .normal)
             activityIndicator.stopAnimating()
         }
          cancelButton.isEnabled = !isLoading
          nameTextField.isEnabled = !isLoading
          usernameTextField.isEnabled = !isLoading
     }

    @objc private func handleCancel() {
        dismiss(animated: true)
    }

    // MARK: - Alert Helper
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
         DispatchQueue.main.async {
              self.present(alertController, animated: true)
         }
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            textField.resignFirstResponder()
            handleSave()
        }
        return true
    }

     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
          if textField == usernameTextField {
               if string.contains(" ") {
                    return false
               }
               let currentText = textField.text ?? ""
               guard let stringRange = Range(range, in: currentText) else { return false }
               let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
               return updatedText.count <= 20
          }
          return true
     }
}

// MARK: - UITextField Extension
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}