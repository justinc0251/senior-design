import UIKit
import FirebaseFirestore
import FirebaseAuth

class LeaderboardViewController: UIViewController {
    
    // MARK: - Properties
    
    private var scores: [(name: String, score: Int)] = []
    private var timeFrame: TimeFrame = .global
    
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
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        setupUI()
        setupConstraints()
        setupEmptyStateLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchLeaderboardData()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(headerView)
        
        titleLabel.text = "Leaderboard"
        titleLabel.font = UIFont(name: "Sen-Bold", size: 28)!
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
        emptyStateLabel.text = "No friends found. Add friends to see their scores here!"
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
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
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
        fetchLeaderboardData()
    }
    
    // MARK: - Data Fetching
    
    private func fetchLeaderboardData() {
        let db = Firestore.firestore()
        
        if timeFrame == .global {
            db.collection("users")
                .order(by: "score", descending: true)
                .limit(to: 10)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error fetching leaderboard data: \(error.localizedDescription)")
                        self.showErrorAlert()
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        print("No documents found.")
                        self.scores = []
                        self.tableView.reloadData()
                        self.emptyStateLabel.isHidden = false // Show empty state if no global scores
                        self.tableView.isHidden = true
                        return
                    }
                    
                    self.scores = documents.compactMap { doc in
                        let data = doc.data()
                        guard let name = data["name"] as? String, let score = data["score"] as? Int else { return nil }
                        return (name, score)
                    }
                    
                    self.emptyStateLabel.isHidden = !self.scores.isEmpty
                    self.tableView.isHidden = self.scores.isEmpty
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
        } else {
            guard let currentUser = Auth.auth().currentUser else {
                self.scores = [] // Clear scores if no user
                self.emptyStateLabel.isHidden = false
                self.tableView.isHidden = true
                self.tableView.reloadData() // Reload to show empty state
                return
            }
            
            // Fetch friends where the current user is the sender
            let query1 = db.collection("friendRequests")
                .whereField("fromUserId", isEqualTo: currentUser.uid)
                .whereField("status", isEqualTo: "accepted")

            // Fetch friends where the current user is the receiver
            let query2 = db.collection("friendRequests")
                .whereField("toUserId", isEqualTo: currentUser.uid)
                .whereField("status", isEqualTo: "accepted")

            let group = DispatchGroup()
            var friendIds = Set<String>() // Use a Set to avoid duplicates

            group.enter()
            query1.getDocuments { snapshot, error in
                defer { group.leave() }
                if let error = error {
                    print("Error fetching friends (query1): \(error.localizedDescription)")
                    // Optionally show error alert
                    return
                }
                snapshot?.documents.forEach { doc in
                    if let toUserId = doc.data()["toUserId"] as? String {
                        friendIds.insert(toUserId)
                    }
                }
            }

            group.enter()
            query2.getDocuments { snapshot, error in
                defer { group.leave() }
                if let error = error {
                    print("Error fetching friends (query2): \(error.localizedDescription)")
                    // Optionally show error alert
                    return
                }
                snapshot?.documents.forEach { doc in
                    if let fromUserId = doc.data()["fromUserId"] as? String {
                        friendIds.insert(fromUserId)
                    }
                }
            }

            group.notify(queue: .main) { [weak self] in
                guard let self = self else { return }

                if friendIds.isEmpty {
                    print("No friends found.")
                    self.scores = []
                    self.emptyStateLabel.isHidden = false
                    self.tableView.isHidden = true
                    self.tableView.reloadData()
                    return
                }

                var friendScores: [(name: String, score: Int)] = []
                let fetchGroup = DispatchGroup()

                for friendId in friendIds {
                    fetchGroup.enter()
                    db.collection("users").document(friendId).getDocument { snapshot, error in
                        defer { fetchGroup.leave() }
                        
                        if let error = error {
                            print("Error fetching friend data for \(friendId): \(error.localizedDescription)")
                            return
                        }
                        
                        if let data = snapshot?.data(),
                           let name = data["name"] as? String,
                           let score = data["score"] as? Int {
                            friendScores.append((name: name, score: score))
                        }
                    }
                }
                
                // Also fetch current user's score to include in friends list
                fetchGroup.enter()
                db.collection("users").document(currentUser.uid).getDocument { snapshot, error in
                    defer { fetchGroup.leave() }
                    if let error = error {
                        print("Error fetching current user data: \(error.localizedDescription)")
                        return
                    }
                    if let data = snapshot?.data(),
                       let name = data["name"] as? String,
                       let score = data["score"] as? Int {
                        friendScores.append((name: name, score: score))
                    }
                }

                fetchGroup.notify(queue: .main) {
                    self.scores = friendScores.sorted(by: { $0.score > $1.score })
                    self.emptyStateLabel.isHidden = !self.scores.isEmpty
                    self.tableView.isHidden = self.scores.isEmpty
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Failed to load leaderboard data. Please try again later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension LeaderboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as? LeaderboardCell else {
            return UITableViewCell()
        }
        
        let scoreData = scores[indexPath.row]
        cell.configure(with: scoreData.name, points: scoreData.score, rank: indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // Keep consistent height
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
    private let accentColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
    
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
        backgroundColor = .clear // Ensure cell background is clear
        contentView.backgroundColor = .clear // Ensure content view background is clear
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 15
        containerView.layer.masksToBounds = false // Allow shadow if needed later
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView) // Add to contentView
        
        rankLabel.font = UIFont(name: "Sen-Regular", size: 18)!
        rankLabel.textColor = .lightGray
        rankLabel.textAlignment = .center
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(rankLabel)
        
        avatarImageView.backgroundColor = accentColor
        avatarImageView.layer.cornerRadius = 25 // Half of width/height
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.white.cgColor // Optional: border for definition
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(avatarImageView)
        
        avatarLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        avatarLabel.textColor = .white
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.addSubview(avatarLabel) // Add label inside image view
        
        usernameLabel.font = UIFont(name: "Sen-Regular", size: 18)!
        usernameLabel.textColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(usernameLabel)
        
        pointsLabel.font = UIFont(name: "Sen-Regular", size: 16)!
        pointsLabel.textColor = .gray
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(pointsLabel)
        
        // Constraints using contentView anchors for margins
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0), // Adjust if table view has padding
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0), // Adjust if table view has padding
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            rankLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            rankLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 30), // Fixed width for rank
            
            avatarImageView.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 10),
            avatarImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Center avatar label within avatar image view
            avatarLabel.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            usernameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 2), // Align top slightly offset
            usernameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15), // Add trailing padding
            
            pointsLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            pointsLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4), // Space below username
            pointsLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor) // Align trailing with username
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with username: String, points: Int, rank: Int) {
        usernameLabel.text = username
        pointsLabel.text = "\(points) points"
        rankLabel.text = "\(rank)"
        
        // Set avatar initial
        if let firstLetter = username.first {
            avatarLabel.text = String(firstLetter).uppercased()
        } else {
            avatarLabel.text = "?" // Fallback if username is empty
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset labels and image view content if necessary
        usernameLabel.text = nil
        pointsLabel.text = nil
        rankLabel.text = nil
        avatarLabel.text = nil
        // avatarImageView.image = nil // If using actual images
    }
}