import UIKit
import FirebaseFirestore
import FirebaseAuth

class LeaderboardViewController: UIViewController {
    
    private var scores: [(name: String, score: Int)] = []
    private var timeFrame: TimeFrame = .global
    
    enum TimeFrame {
        case friends
        case global
    }
    
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let segmentedControl = UISegmentedControl(items: ["Global", "Friends"])
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    
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
    
    private func setupUI() {
        view.addSubview(headerView)
        
        titleLabel.text = "Leaderboard"
        titleLabel.font = UIFont(name: "Sen-Regular", size: 24)!
        titleLabel.textColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        
        segmentedControl.selectedSegmentIndex = 0 
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmentedControl.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        segmentedControl.selectedSegmentTintColor = UIColor(red: 141/255, green: 212/255, blue: 109/255, alpha: 1)
        
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
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        timeFrame = sender.selectedSegmentIndex == 0 ? .global : .friends
        fetchLeaderboardData()
    }
    
    private func fetchLeaderboardData() {
        // Show loading indicator
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        spinner.center = view.center
        view.addSubview(spinner)
        
        let db = Firestore.firestore()
        
        if timeFrame == .global {
            // Global leaderboard - fetch top scores from all users
            db.collection("users")
                .order(by: "score", descending: true)
                .limit(to: 10)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    spinner.removeFromSuperview()
                    
                    if let error = error {
                        print("Error fetching leaderboard data: \(error.localizedDescription)")
                        self.showErrorAlert()
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        print("No documents found.")
                        self.scores = []
                        self.tableView.reloadData()
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
            // Friends leaderboard
            guard let currentUser = Auth.auth().currentUser else {
                spinner.removeFromSuperview()
                self.emptyStateLabel.isHidden = false
                self.tableView.isHidden = true
                return
            }
            
            // Get user's friend list - UPDATED to use friendRequests collection
            db.collection("friendRequests")
                .whereField("fromUserId", isEqualTo: currentUser.uid)
                .whereField("status", isEqualTo: "accepted")
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error fetching friends: \(error.localizedDescription)")
                        spinner.removeFromSuperview()
                        self.showErrorAlert()
                        return
                    }
                    
                    // No friend requests found
                    guard let documents = snapshot?.documents, !documents.isEmpty else {
                        print("No friends found.")
                        spinner.removeFromSuperview()
                        self.scores = []
                        self.emptyStateLabel.isHidden = false
                        self.tableView.isHidden = true
                        return
                    }
                    
                    let friendIds = documents.compactMap { $0.data()["toUserId"] as? String }
                    
                    var friendScores: [(name: String, score: Int)] = []
                    let group = DispatchGroup()
                    
                    for friendId in friendIds {
                        group.enter()
                        db.collection("users").document(friendId).getDocument { snapshot, error in
                            defer { group.leave() }
                            
                            if let error = error {
                                print("Error fetching friend data: \(error.localizedDescription)")
                                return
                            }
                            
                            if let data = snapshot?.data(),
                               let name = data["name"] as? String,
                               let score = data["score"] as? Int {
                                friendScores.append((name: name, score: score))
                            }
                        }
                    }
                    
                    group.notify(queue: .main) {
                        spinner.removeFromSuperview()
                        self.scores = friendScores.sorted(by: { $0.score > $1.score })
                        self.emptyStateLabel.isHidden = !self.scores.isEmpty
                        self.tableView.isHidden = self.scores.isEmpty
                        self.tableView.reloadData()
                    }
                }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Failed to load leaderboard data. Please try again later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension LeaderboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as? LeaderboardCell else {
            return UITableViewCell()
        }
        
        let score = scores[indexPath.row]
        cell.configure(with: score.name, points: score.score, rank: indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

class LeaderboardCell: UITableViewCell {
    private let containerView = UIView()
    private let rankLabel = UILabel()
    private let avatarImageView = UIImageView()
    private let avatarLabel = UILabel()
    private let usernameLabel = UILabel()
    private let pointsLabel = UILabel()
    private let accentColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 15
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        rankLabel.font = UIFont(name: "Sen-Regular", size: 18)!
        rankLabel.textColor = .lightGray
        rankLabel.textAlignment = .center
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(rankLabel)
        
        // Setup avatar with same style as profile view
        avatarImageView.backgroundColor = accentColor
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(avatarImageView)
        
        // Add avatar label for initial
        avatarLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        avatarLabel.textColor = .white
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
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            rankLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            rankLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 30),
            
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
            pointsLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor)
        ])
    }
    
    func configure(with username: String, points: Int, rank: Int) {
        usernameLabel.text = username
        pointsLabel.text = "\(points) points"
        rankLabel.text = "\(rank)"
        
        // Set avatar label to first letter of username
        if let firstLetter = username.first {
            avatarLabel.text = String(firstLetter)
        } else {
            avatarLabel.text = "?"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        pointsLabel.text = nil
        rankLabel.text = nil
        avatarLabel.text = nil
    }
}