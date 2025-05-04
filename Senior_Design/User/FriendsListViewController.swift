import UIKit
import FirebaseFirestore
import FirebaseAuth

class FriendsListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let tableView = UITableView()
    private let emptyStateView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    var accentColor: UIColor = .systemBlue
    private var friends: [(userId: String, username: String, name: String)] = []
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchFriends()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Friends"
        view.backgroundColor = .white
        
        setupTableView()
        setupEmptyState()
        setupActivityIndicator()
        setupConstraints()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(FriendCell.self, forCellReuseIdentifier: "FriendCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
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
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = accentColor
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func updateEmptyStateVisibility() {
        emptyStateView.isHidden = !friends.isEmpty
        tableView.isHidden = friends.isEmpty
    }
    
    // MARK: - Data Fetching
    
    private func fetchFriends() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        
        let query1 = db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: "accepted")

        let query2 = db.collection("friendRequests")
            .whereField("toUserId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: "accepted")

        let group = DispatchGroup()
        var friendIds = Set<String>()

        group.enter()
        query1.getDocuments { snapshot, error in
            defer { group.leave() }
            if let error = error {
                print("Error fetching friends (query1): \(error.localizedDescription)")
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
                self.friends = []
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
                self.updateEmptyStateVisibility()
                return
            }
            
            var tempFriends: [(userId: String, username: String, name: String)] = []
            let fetchGroup = DispatchGroup()
            
            for friendId in friendIds {
                fetchGroup.enter()
                db.collection("users").document(friendId).getDocument { snapshot, error in
                    defer { fetchGroup.leave() }
                    
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
            
            fetchGroup.notify(queue: .main) {
                self.friends = tempFriends.sorted { $0.name.lowercased() < $1.name.lowercased() }
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
                self.updateEmptyStateVisibility()
            }
        }
    }
    
    // MARK: - Actions & Alerts

    private func showRemoveFriendConfirmation(for friend: (userId: String, username: String, name: String), at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Remove Friend", message: "Are you sure you want to remove @\(friend.username) as a friend?", preferredStyle: .actionSheet)
        
        let removeAction = UIAlertAction(title: "Remove Friend", style: .destructive) { [weak self] _ in
            self?.removeFriend(friend, at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            if let cell = tableView.cellForRow(at: indexPath) {
                popoverController.sourceView = cell
                popoverController.sourceRect = cell.bounds
            } else {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            }
            popoverController.permittedArrowDirections = []
        }
        
        present(alertController, animated: true, completion: nil)
    }

    private func removeFriend(_ friend: (userId: String, username: String, name: String), at indexPath: IndexPath) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        let query1 = db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: currentUserId)
            .whereField("toUserId", isEqualTo: friend.userId)
            .whereField("status", isEqualTo: "accepted")
            .limit(to: 1)

        let query2 = db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: friend.userId)
            .whereField("toUserId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: "accepted")
            .limit(to: 1)

        let group = DispatchGroup()

        group.enter()
        query1.getDocuments { snapshot, error in
            if let doc = snapshot?.documents.first {
                batch.deleteDocument(doc.reference)
            }
            group.leave()
        }

        group.enter()
        query2.getDocuments { snapshot, error in
            if let doc = snapshot?.documents.first {
                batch.deleteDocument(doc.reference)
            }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            batch.commit { error in
                guard let self = self else { return }
                if let error = error {
                    print("Error removing friend relationship: \(error.localizedDescription)")
                    // TODO: Show error alert to user
                } else {
                    print("Successfully removed friend relationship with \(friend.username)")
                    self.friends.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.updateEmptyStateVisibility()
                }
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
        
        cell.onRemoveFriend = { [weak self] in
            self?.showRemoveFriendConfirmation(for: friend, at: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Navigate to friend's profile if desired
    }
}

// MARK: - Friend Cell
class FriendCell: UITableViewCell {
    
    // MARK: - Properties
    
    private let avatarView = UIView()
    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let removeButton = UIButton(type: .system)
    
    var onRemoveFriend: (() -> Void)?
    
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
        backgroundColor = .white
        
        setupViews()
        setupConstraints()
        setupSeparator()
    }
    
    private func setupViews() {
        avatarView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        avatarView.layer.cornerRadius = 25
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarView)
        
        avatarLabel.font = UIFont(name: "Sen-Regular", size: 18)
        avatarLabel.textColor = .white
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(avatarLabel)
        
        nameLabel.font = UIFont(name: "Sen-Regular", size: 16)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        usernameLabel.font = UIFont(name: "Sen-Regular", size: 14)
        usernameLabel.textColor = .darkGray
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(usernameLabel)
        
        removeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        removeButton.tintColor = .systemGray
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(removeButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: removeButton.leadingAnchor, constant: -12),
            
            usernameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: removeButton.leadingAnchor, constant: -12),

            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            removeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: 30),
            removeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupSeparator() {
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
    
    // MARK: - Actions
    
    @objc private func removeButtonTapped() {
        onRemoveFriend?()
    }
    
    // MARK: - Configuration
    
    func configure(username: String, name: String, accentColor: UIColor) {
        nameLabel.text = name
        usernameLabel.text = "@\(username)"
        
        if let initial = name.first {
            avatarLabel.text = String(initial)
        } else {
            avatarLabel.text = "?"
        }
        
        avatarView.backgroundColor = accentColor
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        usernameLabel.text = nil
        avatarLabel.text = nil
        onRemoveFriend = nil
    }
}