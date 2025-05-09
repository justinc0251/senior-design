import UIKit
import FirebaseFirestore
import FirebaseAuth

class LeaderboardViewController: UIViewController {

    // MARK: - Properties
    private var globalScores: [(userId: String, name: String, score: Int, profileColor: String)] = []
    private var friendsScores: [(userId: String, name: String, score: Int, profileColor: String)] = []
    private var globalCurrentUserRank: Int?
    private var globalCurrentUserScoreData: (userId: String, name: String, score: Int, profileColor: String)?

    private var displayedScores: [(userId: String, name: String, score: Int, profileColor: String)] = []
    private var displayedCurrentUserRank: Int?
    private var displayedCurrentUserScoreData: (userId: String, name: String, score: Int, profileColor: String)?

    private var timeFrame: TimeFrame = .global
    private var isFetchingData = false
    private var hasFetchedDataThisSession = false

    enum TimeFrame {
        case friends
        case global
    }

    // MARK: - UI Components

    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let segmentedControl = UISegmentedControl(items: ["Global", "Friends"])
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        setupUI()
        setupConstraints()
        setupEmptyStateLabel()
        setupActivityIndicator()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !hasFetchedDataThisSession {
            fetchAllLeaderboardData()
        } else {
             updateTableViewDisplay()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hasFetchedDataThisSession = false
    }


    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(headerView)

        titleLabel.text = "Leaderboard"
        titleLabel.font = UIFont(name: "Sen-Bold", size: 32)!
        titleLabel.textColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmentedControl.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        segmentedControl.selectedSegmentTintColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont(name: "Sen-Regular", size: 18)!
        ]
        segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)

        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "Sen-Regular", size: 18)!
        ]
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)

        view.addSubview(segmentedControl)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LeaderboardCell.self, forCellReuseIdentifier: "LeaderboardCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
    }

    private func setupEmptyStateLabel() {
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "No data available."
        emptyStateLabel.font = UIFont(name: "Sen-Regular", size: 16)
        emptyStateLabel.textColor = .gray
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Constraints Setup

    private func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),

            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.widthAnchor.constraint(equalToConstant: 240),
            segmentedControl.heightAnchor.constraint(equalToConstant: 44),

            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }


    // MARK: - Actions

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        timeFrame = sender.selectedSegmentIndex == 0 ? .global : .friends
        updateTableViewDisplay()
    }

    // MARK: - Data Fetching and Display Logic

    private func fetchAllLeaderboardData() {
        guard !isFetchingData else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            handleLoggedOutState()
            return
        }

        isFetchingData = true
        DispatchQueue.main.async {
            self.tableView.isHidden = true
            self.emptyStateLabel.isHidden = true
            self.activityIndicator.startAnimating()
        }

        let db = Firestore.firestore()
        let group = DispatchGroup()
        var fetchError: Error? = nil

        group.enter()
        fetchGlobalLeaderboard(userId: currentUserId, db: db) { [weak self] error in
            if let error = error {
                print("Error fetching global data: \(error.localizedDescription)")
                fetchError = fetchError ?? error
            }
            group.leave()
        }

        group.enter()
        fetchFriendsLeaderboard(userId: currentUserId, db: db) { [weak self] error in
            if let error = error {
                print("Error fetching friends data: \(error.localizedDescription)")
                fetchError = fetchError ?? error
            }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isFetchingData = false
            self.hasFetchedDataThisSession = true
            self.activityIndicator.stopAnimating()

            if let error = fetchError {
                self.showErrorAlert(message: "Failed to load some leaderboard data: \(error.localizedDescription)")
            }

            self.updateTableViewDisplay()
        }
    }

    private func fetchGlobalLeaderboard(userId: String, db: Firestore, completion: @escaping (Error?) -> Void) {
        db.collection("users")
            .order(by: "score", descending: true)
            .limit(to: 10)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { completion(error); return }

                if let error = error {
                    completion(error)
                    return
                }
                guard let documents = snapshot?.documents else {
                    self.globalScores = []
                    completion(nil)
                    return
                }

                // Fetch profileColor along with other data
                let top10 = documents.compactMap { doc -> (userId: String, name: String, score: Int, profileColor: String)? in
                    let data = doc.data()
                    guard let name = data["name"] as? String,
                          let score = data["score"] as? Int else { return nil }
                    let profileColor = data["profileColor"] as? String ?? "#4CBB7B" // Default color
                    return (userId: doc.documentID, name: name, score: score, profileColor: profileColor)
                }
                self.globalScores = top10

                let userIsInTop10 = top10.contains { $0.userId == userId }

                if userIsInTop10 {
                    self.globalCurrentUserRank = nil
                    self.globalCurrentUserScoreData = nil
                    completion(nil)
                } else {
                    self.fetchCurrentUserRankAndData(currentUserId: userId, db: db) { rankError in
                        completion(rankError)
                    }
                }
            }
    }

    private func fetchFriendsLeaderboard(userId: String, db: Firestore, completion: @escaping (Error?) -> Void) {
        let query1 = db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: userId)
            .whereField("status", isEqualTo: "accepted")
        let query2 = db.collection("friendRequests")
            .whereField("toUserId", isEqualTo: userId)
            .whereField("status", isEqualTo: "accepted")

        let group = DispatchGroup()
        var friendIds = Set<String>()
        var queryError: Error? = nil

        group.enter()
        query1.getDocuments { snapshot, error in
            if let error = error { queryError = queryError ?? error }
            snapshot?.documents.forEach { doc in
                if let toUserId = doc.data()["toUserId"] as? String { friendIds.insert(toUserId) }
            }
            group.leave()
        }

        group.enter()
        query2.getDocuments { snapshot, error in
            if let error = error { queryError = queryError ?? error }
            snapshot?.documents.forEach { doc in
                if let fromUserId = doc.data()["fromUserId"] as? String { friendIds.insert(fromUserId) }
            }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { completion(queryError); return }

            if let error = queryError {
                self.friendsScores = []
                completion(error)
                return
            }

            // Add current user ID to the set to fetch their data as well for the friends list
            friendIds.insert(userId)

            if friendIds.isEmpty { // Should not happen now as current user is included
                self.friendsScores = []
                completion(nil)
                return
            }


            var fetchedFriendScores: [(userId: String, name: String, score: Int, profileColor: String)] = []
            let fetchGroup = DispatchGroup()
            var friendFetchError: Error? = nil

            for friendId in friendIds {
                fetchGroup.enter()
                db.collection("users").document(friendId).getDocument { snapshot, error in
                    // Fetch profileColor here too
                    if let data = snapshot?.data(),
                       let name = data["name"] as? String,
                       let score = data["score"] as? Int {
                        let profileColor = data["profileColor"] as? String ?? "#4CBB7B" // Default color
                        fetchedFriendScores.append((userId: friendId, name: name, score: score, profileColor: profileColor))
                    } else if let error = error {
                        print("Error fetching friend data for \(friendId): \(error.localizedDescription)")
                        friendFetchError = friendFetchError ?? error
                    }
                    fetchGroup.leave()
                }
            }

            fetchGroup.notify(queue: .main) {
                // Sort by score after fetching all friends
                self.friendsScores = fetchedFriendScores.sorted { $0.score > $1.score }
                completion(friendFetchError)
            }
        }
    }

    private func fetchCurrentUserRankAndData(currentUserId: String, db: Firestore, completion: @escaping (Error?) -> Void) {
        let userDocRef = db.collection("users").document(currentUserId)
        var fetchError: Error? = nil

        userDocRef.getDocument { [weak self] userSnapshot, userError in
            guard let self = self else { completion(userError); return }

            if let userError = userError {
                print("Error fetching current user data: \(userError.localizedDescription)")
                self.globalCurrentUserRank = nil
                self.globalCurrentUserScoreData = nil
                completion(userError)
                return
            }

            guard let userData = userSnapshot?.data(),
                  let userName = userData["name"] as? String,
                  let userScore = userData["score"] as? Int else {
                print("Could not parse current user data.")
                self.globalCurrentUserRank = nil
                self.globalCurrentUserScoreData = nil
                completion(nil)
                return
            }
             // Fetch profileColor for the current user
            let profileColor = userData["profileColor"] as? String ?? "#4CBB7B" // Default color

            self.globalCurrentUserScoreData = (userId: currentUserId, name: userName, score: userScore, profileColor: profileColor)

            db.collection("users")
              .whereField("score", isGreaterThan: userScore)
              .count
              .getAggregation(source: .server) { [weak self] (snapshot, error) in
                  guard let self = self else { completion(error); return }
                  if let error = error {
                      print("Error counting users for rank: \(error.localizedDescription)")
                      self.globalCurrentUserRank = nil
                      fetchError = error
                  } else if let count = snapshot?.count {
                      self.globalCurrentUserRank = count.intValue + 1
                      print("Current user rank calculated: \(self.globalCurrentUserRank ?? -1)")
                  } else {
                      print("Could not get count for rank.")
                      self.globalCurrentUserRank = nil
                  }
                  completion(fetchError)
              }
        }
    }

    private func updateTableViewDisplay() {
        DispatchQueue.main.async {
            if self.timeFrame == .global {
                self.displayedScores = self.globalScores
                self.displayedCurrentUserRank = self.globalCurrentUserRank
                self.displayedCurrentUserScoreData = self.globalCurrentUserScoreData
                let hasData = !self.displayedScores.isEmpty || self.displayedCurrentUserScoreData != nil
                self.emptyStateLabel.isHidden = hasData
                self.tableView.isHidden = !hasData
                if !hasData { self.emptyStateLabel.text = "Leaderboard is empty." }
            } else {
                // Logic for Friends tab
                self.displayedScores = self.friendsScores
                self.displayedCurrentUserRank = nil // Rank is implicit by position
                self.displayedCurrentUserScoreData = nil // User is part of the main list

                // Check if the user has at least one friend (list includes the user themselves)
                let hasFriends = self.friendsScores.count > 1
                let hasData = !self.friendsScores.isEmpty && hasFriends // Show table only if there are friends + user

                self.emptyStateLabel.isHidden = hasData
                self.tableView.isHidden = !hasData

                if !hasData {
                     // If the list only contains the current user, it means no friends added
                    if self.friendsScores.count == 1 && self.friendsScores.first?.userId == Auth.auth().currentUser?.uid {
                         self.emptyStateLabel.text = "No friends found. Add friends via Profile to see them here!"
                    } else if self.friendsScores.isEmpty {
                         // Handles cases where data might still be loading or truly empty
                         self.emptyStateLabel.text = "No friends found or data is loading.\nAdd friends via Profile to see them here!"
                    } else {
                         // Fallback - should ideally not be reached if fetch includes user
                          self.emptyStateLabel.text = "No friends found. Add friends via Profile to see them here!"
                    }

                }
            }
            self.tableView.reloadData()
        }
    }


    private func handleLoggedOutState() {
        self.globalScores = []
        self.friendsScores = []
        self.globalCurrentUserRank = nil
        self.globalCurrentUserScoreData = nil
        self.displayedScores = []
        self.displayedCurrentUserRank = nil
        self.displayedCurrentUserScoreData = nil
        self.emptyStateLabel.text = "Please log in to view leaderboards."

        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.emptyStateLabel.isHidden = false
            self.tableView.isHidden = true
            self.tableView.reloadData()
        }
    }


    // MARK: - Helper Methods

    private func showErrorAlert(message: String = "Failed to load leaderboard data. Please try again later.") {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            if self.view.window != nil {
                 self.present(alert, animated: true)
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension LeaderboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         // Global: top 10 + potentially current user
         // Friends: Just the list of friends (which includes the current user)
        return (timeFrame == .global && displayedCurrentUserScoreData != nil) ? displayedScores.count + 1 : displayedScores.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as? LeaderboardCell else {
            return UITableViewCell()
        }

        let currentUserId = Auth.auth().currentUser?.uid
        var isCurrentUserCell = false
        let defaultColor = "#4CBB7B" // Define a default color hex

        if indexPath.row < displayedScores.count {
            // Displaying users from the top 10 (global) or friends list
            let scoreData = displayedScores[indexPath.row]
             // Correct ranking for friends list: Use the index + 1 directly
            let rank = indexPath.row + 1

            cell.configure(with: scoreData.name,
                           points: scoreData.score,
                           rank: rank,
                           profileColorHex: scoreData.profileColor) // Pass color hex
            isCurrentUserCell = scoreData.userId == currentUserId
            cell.setSeparatorVisibility(visible: true) // Separator for regular rows

            // Highlight if it's the current user within the displayed list (applies to both global top 10 and friends list)
             // Use isSpecialRank: false for users within the normal list flow
            cell.setHighlight(isHighlighted: isCurrentUserCell, isSpecialRank: false)


        } else if timeFrame == .global, let userData = displayedCurrentUserScoreData, let rank = displayedCurrentUserRank {
            // Displaying the current user separately (ONLY for global view, if not in top 10)
            cell.configure(with: userData.name,
                           points: userData.score,
                           rank: rank,
                           profileColorHex: userData.profileColor) // Pass color hex
            isCurrentUserCell = true
            cell.setSeparatorVisibility(visible: false) // No separator for the special rank cell
            cell.setHighlight(isHighlighted: true, isSpecialRank: true) // Special highlight for separate rank row

            // Add bottom separator to the previous cell (the last cell of the top 10)
            if let previousCell = tableView.cellForRow(at: IndexPath(row: indexPath.row - 1, section: 0)) as? LeaderboardCell {
                previousCell.addBottomSeparator()
            }

        } else {
             // Fallback / Error case - Should ideally not happen in friends view if fetch is correct
             cell.configure(with: "Error", points: 0, rank: 0, profileColorHex: defaultColor)
             cell.setSeparatorVisibility(visible: false)
             cell.setHighlight(isHighlighted: false, isSpecialRank: false)
        }

        return cell
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Make the special current user rank cell taller (Only applies in Global view)
        if timeFrame == .global && indexPath.row == displayedScores.count && displayedCurrentUserScoreData != nil {
            return 110
        }
        return 100 // Standard height for other cells
    }
}


// MARK: - LeaderboardCell
class LeaderboardCell: UITableViewCell {

    // MARK: - Properties

    private let containerView = UIView()
    private let rankLabel = UILabel()
    private let avatarImageView = UIImageView()
    private let avatarLabel = UILabel()
    private let usernameLabel = UILabel()
    private let pointsLabel = UILabel()
    // Keep accentColor if needed for highlighting, but avatar background will use profileColor
    private let accentColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
    private let separatorView = UIView()
    private let bottomSeparatorView = UIView()


    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Cell Setup

    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 15
        containerView.layer.masksToBounds = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        rankLabel.font = UIFont(name: "Sen-Regular", size: 18)!
        rankLabel.textColor = .lightGray
        rankLabel.textAlignment = .center
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(rankLabel)

        // Avatar setup remains similar, background color will be set in configure
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(avatarImageView)

        avatarLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        avatarLabel.textColor = .white // Assuming white text looks good on most profile colors
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.addSubview(avatarLabel)

        usernameLabel.font = UIFont(name: "Sen-Regular", size: 18)!
        usernameLabel.textColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(usernameLabel)

        pointsLabel.font = UIFont(name: "Sen-Regular", size: 16)!
        pointsLabel.textColor = .gray
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(pointsLabel)

        separatorView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorView)

        bottomSeparatorView.backgroundColor = UIColor.lightGray
        bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparatorView.isHidden = true
        contentView.addSubview(bottomSeparatorView)


        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),

            rankLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            rankLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 40),

            avatarImageView.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 10),
            avatarImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),

            avatarLabel.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),

            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            usernameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 2),
            usernameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),

            pointsLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            pointsLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            pointsLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),

            separatorView.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            separatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),

             bottomSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
             bottomSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
             bottomSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
             bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    // MARK: - Configuration
    // Update configure method to accept profileColorHex
     func configure(with username: String, points: Int, rank: Int, profileColorHex: String, isRankApproximate: Bool = false) {
         usernameLabel.text = username
         pointsLabel.text = "\(points) points"

         if isRankApproximate {
             rankLabel.text = "..." // Or handle appropriately
         } else {
             rankLabel.text = "\(rank)"
         }

         if let firstLetter = username.first {
             avatarLabel.text = String(firstLetter).uppercased()
         } else {
             avatarLabel.text = "?"
         }

         // Set avatar background color using the hex string
         avatarImageView.backgroundColor = UIColor.fromHex(profileColorHex) ?? accentColor // Fallback to accentColor
     }


    func setSeparatorVisibility(visible: Bool) {
        separatorView.isHidden = !visible
    }

     func addBottomSeparator() {
         bottomSeparatorView.isHidden = false
     }

    func setHighlight(isHighlighted: Bool, isSpecialRank: Bool) {
        // Keep highlight logic potentially using accentColor for borders/background tint
        if isHighlighted {
            containerView.backgroundColor = accentColor.withAlphaComponent(0.1)
            containerView.layer.borderColor = accentColor.cgColor
            containerView.layer.borderWidth = isSpecialRank ? 0 : 1.5 // Only add border if not special rank
            rankLabel.textColor = accentColor
            usernameLabel.textColor = accentColor // Highlight text as well
        } else {
            containerView.backgroundColor = .white
            containerView.layer.borderWidth = 0
            rankLabel.textColor = .lightGray
            usernameLabel.textColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0) // Reset text color
        }
         // Add transform for special rank cell only if it's highlighted
         containerView.transform = (isHighlighted && isSpecialRank) ? CGAffineTransform(translationX: 0, y: 10) : .identity

    }


    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        pointsLabel.text = nil
        rankLabel.text = nil
        avatarLabel.text = nil
        avatarImageView.backgroundColor = accentColor // Reset to default before reuse
        setHighlight(isHighlighted: false, isSpecialRank: false)
        setSeparatorVisibility(visible: true)
        bottomSeparatorView.isHidden = true
        containerView.transform = .identity
    }
}
