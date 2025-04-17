import UIKit
import FirebaseFirestore
import FirebaseAuth

// MARK: -  User Search
class UserSearchViewController: UIViewController {
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let emptyStateView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    var accentColor: UIColor = .systemBlue
    
    private var searchResults: [(username: String, name: String, userId: String)] = []
    private var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Find Friends"
        view.backgroundColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissSearch)
        )
        
        searchBar.placeholder = "Search by username or name"
        searchBar.delegate = self
        searchBar.searchTextField.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        searchBar.tintColor = accentColor
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: "SearchResultCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        setupEmptyState()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = accentColor
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
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
        
        let imageView = UIImageView(image: UIImage(systemName: "person.3"))
        imageView.tintColor = UIColor(white: 0.8, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(imageView)
        
        let label = UILabel()
        label.text = "Search for users to add as friends"
        label.textColor = .darkGray
        label.font = UIFont(name: "Sen-Regular", size: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(label)
        
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
            label.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
        
        updateEmptyStateVisibility()
    }
    
    private func updateEmptyStateVisibility() {
        emptyStateView.isHidden = isSearching || !searchResults.isEmpty
    }
    
    private func searchUsers(with query: String) {
        isSearching = true
        activityIndicator.startAnimating()
        updateEmptyStateVisibility()
        
        let db = Firestore.firestore()
        
        guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else {
            print("Warning: Could not get current user ID")
            return
        }
        
        db.collection("users")
            .limit(to: 50)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isSearching = false
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    print("Error searching for users: \(error.localizedDescription)")
                    self.searchResults = []
                    self.tableView.reloadData()
                    self.updateEmptyStateVisibility()
                    return
                } else if let documents = snapshot?.documents {
                    let allUsers = documents.compactMap { doc -> (username: String, name: String, userId: String)? in
                        let data = doc.data()
                        let username = data["username"] as? String ?? "user"
                        let name = data["name"] as? String ?? "Unknown"
                        let userId = doc.documentID
                        
                        if userId == currentUserId {
                            return nil
                        }
                        
                        return (username: username, name: name, userId: userId)
                    }
                    db.collection("friendRequests")
                        .whereField("fromUserId", isEqualTo: currentUserId)
                        .whereField("status", in: ["pending","accepted"])
                        .getDocuments { [weak self] fromSnapshot, error in
                            guard let self = self else{ return }
                            var excludedUserIds = Set<String>()
                            for doc in fromSnapshot?.documents ?? [] {
                                let data=doc.data()
                                if let toUserId = data["toUserId"] as? String {
                                    excludedUserIds.insert(toUserId)
                                }
                            }
                            db.collection("friendRequests")
                                .whereField("toUserId", isEqualTo: currentUserId)
                                .whereField("status", in: ["pending", "accepted"])
                                .getDocuments { [weak self] toSnapshot, error in
                                    guard let self = self else {return}
                                    
                                    for doc in toSnapshot?.documents ?? [] {
                                        let data = doc.data()
                                        if let fromUserId = data["fromUserId"] as? String{
                                            excludedUserIds.insert(fromUserId)
                                        }
                                    }
                                    if !query.isEmpty {
                                        let lowercaseQuery = query.lowercased()
                                        self.searchResults = allUsers.filter {
                                            !$0.userId.isEmpty &&
                                            !excludedUserIds.contains($0.userId) &&
                                            (
                                                $0.name.lowercased().contains(lowercaseQuery) ||
                                                $0.username.lowercased().contains(lowercaseQuery)
                                            )
                                        }
                                    } else {
                                        self.searchResults = allUsers.filter{
                                            !excludedUserIds.contains($0.userId)
                                        }
                                    }
                                    self.tableView.reloadData()
                                    self.updateEmptyStateVisibility()
                                }
                        }
                } else {
                    self.searchResults = []
                    self.tableView.reloadData()
                    self.updateEmptyStateVisibility()
                }
            }
    }
    
    @objc private func dismissSearch() {
        dismiss(animated: true)
    }
    
    private func sendFriendRequest(to userId: String, username: String) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else {
            showError(message: "You need to be logged in to add friends")
            return
        }
        
        let db = Firestore.firestore()
        
        let requestData: [String: Any] = [
            "fromUserId": currentUserId,
            "toUserId": userId,
            "status": "pending",
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("friendRequests").addDocument(data: requestData) { [weak self] error in
            if let error = error {
                self?.showError(message: "Error sending friend request: \(error.localizedDescription)")
                return
            }
            
            self?.showSuccessMessage(username: username)
        }
    }
    
    private func showSuccessMessage(username: String) {
        let successView = UIView()
        successView.backgroundColor = accentColor
        successView.alpha = 0
        successView.layer.cornerRadius = 8
        successView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(successView)
        
        let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmark.tintColor = .white
        checkmark.contentMode = .scaleAspectFit
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        successView.addSubview(checkmark)
        
        let label = UILabel()
        label.text = "Friend request sent to @\(username)!"
        label.textColor = .white
        label.font = UIFont(name: "Sen-Regular", size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        successView.addSubview(label)
        
        NSLayoutConstraint.activate([
            successView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            successView.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            successView.heightAnchor.constraint(equalToConstant: 44),
            
            checkmark.leadingAnchor.constraint(equalTo: successView.leadingAnchor, constant: 16),
            checkmark.centerYAnchor.constraint(equalTo: successView.centerYAnchor),
            checkmark.widthAnchor.constraint(equalToConstant: 20),
            checkmark.heightAnchor.constraint(equalToConstant: 20),
            
            label.leadingAnchor.constraint(equalTo: checkmark.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: successView.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: successView.centerYAnchor)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            successView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
                successView.alpha = 0
            }, completion: { _ in
                successView.removeFromSuperview()
            })
        })
    }
    
    private func showError(message: String) {
        let alertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        
        present(alertController, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension UserSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchUsers(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension UserSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as? SearchResultCell else {
            return UITableViewCell()
        }
        
        let result = searchResults[indexPath.row]
        cell.configure(username: result.username, name: result.name, accentColor: accentColor)
        
        cell.onAddFriend = { [weak self] in
            self?.sendFriendRequest(to: result.userId, username: result.username)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Search Result Cell
class SearchResultCell: UITableViewCell {
    
    private let avatarView = UIView()
    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let addButton = UIButton(type: .system)
    
    var onAddFriend: (() -> Void)?
    
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
        
        addButton.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
        addButton.backgroundColor = .clear
        addButton.layer.cornerRadius = 15
        addButton.layer.borderWidth = 1
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -12),
            
            usernameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -12),
            
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 30),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
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
        
        if let initial = name.first {
            avatarLabel.text = String(initial)
        }
        
        avatarView.backgroundColor = accentColor
        addButton.tintColor = accentColor
        addButton.layer.borderColor = accentColor.cgColor
    }
    
    @objc private func addButtonTapped() {
        onAddFriend?()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.addButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.addButton.transform = .identity
            }
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        usernameLabel.text = nil
        avatarLabel.text = nil
        onAddFriend = nil
    }
}
