import UIKit
import FirebaseFirestore
import FirebaseAuth

class FriendsListViewController: UIViewController {
    
    private let tableView = UITableView()
    private let emptyStateView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    var accentColor: UIColor = .systemBlue
    private var friends: [(userId: String, username: String, name: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchFriends()
    }
    
    private func setupUI() {
        title = "Friends"
        view.backgroundColor = .white
        
        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(FriendCell.self, forCellReuseIdentifier: "FriendCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Empty State
        setupEmptyState()
        
        // Activity Indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = accentColor
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        
        let imageView = UIImageView(image: UIImage(systemName: "person.2"))
        imageView.tintColor = UIColor(white: 0.8, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(imageView)
        
        let label = UILabel()
        label.text = "No friends yet"
        label.textColor = .darkGray
        label.font = UIFont(name: "Sen-Regular", size: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(label)
        
        let subLabel = UILabel()
        subLabel.text = "Add friends to see them here"
        subLabel.textColor = .gray
        subLabel.font = UIFont(name: "Sen-Regular", size: 14)
        subLabel.textAlignment = .center
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(subLabel)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            imageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            subLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            subLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            subLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            subLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
        
        updateEmptyStateVisibility()
    }
    
    private func updateEmptyStateVisibility() {
        emptyStateView.isHidden = !friends.isEmpty
        tableView.isHidden = friends.isEmpty
    }
    
    private func fetchFriends() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: "accepted")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching friends: \(error.localizedDescription)")
                    self.activityIndicator.stopAnimating()
                    self.updateEmptyStateVisibility()
                    return
                }
                
                let friendIds = snapshot?.documents.compactMap { $0.data()["toUserId"] as? String } ?? []
                
                if friendIds.isEmpty {
                    self.friends = []
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                    self.updateEmptyStateVisibility()
                    return
                }
                
                var tempFriends: [(userId: String, username: String, name: String)] = []
                let group = DispatchGroup()
                
                for friendId in friendIds {
                    group.enter()
                    db.collection("users").document(friendId).getDocument { snapshot, error in
                        defer { group.leave() }
                        
                        if let error = error {
                            print("Error fetching friend data: \(error.localizedDescription)")
                            return
                        }
                        
                        if let userData = snapshot?.data() {
                            let username = userData["username"] as? String ?? "user"
                            let name = userData["name"] as? String ?? "User"
                            
                            tempFriends.append((
                                userId: friendId,
                                username: username,
                                name: name
                            ))
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    self.friends = tempFriends.sorted { $0.name.lowercased() < $1.name.lowercased() }
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                    self.updateEmptyStateVisibility()
                }
            }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension FriendsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as? FriendCell else {
            return UITableViewCell()
        }
        
        let friend = friends[indexPath.row]
        cell.configure(username: friend.username, name: friend.name, accentColor: accentColor)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - Friend Cell
class FriendCell: UITableViewCell {
    
    private let avatarView = UIView()
    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .white
        
        // Avatar View
        avatarView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        avatarView.layer.cornerRadius = 25
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarView)
        
        // Avatar Label
        avatarLabel.font = UIFont(name: "Sen-Regular", size: 18)
        avatarLabel.textColor = .white
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(avatarLabel)
        
        // Name Label
        nameLabel.font = UIFont(name: "Sen-Regular", size: 16)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        // Username Label
        usernameLabel.font = UIFont(name: "Sen-Regular", size: 14)
        usernameLabel.textColor = .darkGray
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(usernameLabel)
        
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            usernameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        // Add separator
        let separator = UIView()
        separator.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    func configure(username: String, name: String, accentColor: UIColor) {
        nameLabel.text = name
        usernameLabel.text = "@\(username)"
        
        // Create avatar with initials
        if let initial = name.first {
            avatarLabel.text = String(initial)
        }
        
        avatarView.backgroundColor = accentColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        usernameLabel.text = nil
        avatarLabel.text = nil
    }
}
