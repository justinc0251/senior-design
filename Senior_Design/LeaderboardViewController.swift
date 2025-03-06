import UIKit
import FirebaseFirestore

class LeaderboardViewController: UIViewController {
    
    private var scores: [(name: String, score: Int)] = []
    private var timeFrame: TimeFrame = .weekly
    
    enum TimeFrame {
        case weekly
        case allTime
    }
    
    // UI Components
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let segmentedControl = UISegmentedControl(items: ["Weekly", "All Time"])
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
        setupUI()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchLeaderboardData()
    }
    
    private func setupUI() {
        // Header with title
        view.addSubview(headerView)
        
        titleLabel.text = "Leaderboard"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        
        // Segmented control
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmentedControl.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        segmentedControl.selectedSegmentTintColor = UIColor(red: 141/255, green: 212/255, blue: 109/255, alpha: 1)
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        let selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControl.setTitleTextAttributes(selectedTitleTextAttributes, for: .selected)
        
        view.addSubview(segmentedControl)
        
        // TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LeaderboardCell.self, forCellReuseIdentifier: "LeaderboardCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Title
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Segmented Control
            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.widthAnchor.constraint(equalToConstant: 240),
            segmentedControl.heightAnchor.constraint(equalToConstant: 44),
            
            // TableView
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        timeFrame = sender.selectedSegmentIndex == 0 ? .weekly : .allTime
        fetchLeaderboardData()
    }
    
    private func fetchLeaderboardData() {
        let db = Firestore.firestore()
        let collection = timeFrame == .weekly ? "weeklyScores" : "users"
        
        db.collection(collection)
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
                    return
                }
                
                self.scores = documents.compactMap { doc in
                    let data = doc.data()
                    guard let name = data["name"] as? String, let score = data["score"] as? Int else { return nil }
                    return (name, score)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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

// Custom cell for leaderboard entries
class LeaderboardCell: UITableViewCell {
    private let containerView = UIView()
    private let rankLabel = UILabel()
    private let avatarImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let pointsLabel = UILabel()
    
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
        
        // Container view with rounded corners
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 15
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Rank label
        rankLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        rankLabel.textColor = .lightGray
        rankLabel.textAlignment = .center
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(rankLabel)
        
        // Avatar image view
        avatarImageView.backgroundColor = UIColor(red: 175/255, green: 185/255, blue: 200/255, alpha: 1)
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(avatarImageView)
        
        // Username label
        usernameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(usernameLabel)
        
        // Points label
        pointsLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
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
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        pointsLabel.text = nil
        rankLabel.text = nil
    }
}
