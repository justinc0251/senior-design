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

    private let backgroundColor = UIColor.white
    private let cellBackgroundColor = UIColor.white
    private let textPrimaryColor = UIColor.black
    private let textSecondaryColor = UIColor.darkGray
    private let separatorColor = UIColor(white: 0.9, alpha: 1.0)
    private let searchBarBackgroundColor = UIColor(white: 0.95, alpha: 1.0)
    // Use a default background color for the avatar before the actual color is loaded
    private let avatarBackgroundColor = UIColor(white: 0.9, alpha: 1.0)

    // Update searchResults structure to include profileColor
    private var searchResults: [(username: String, name: String, userId: String, profileColor: String)] = []
    private var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        searchUsers(with: "")
    }

    private func setupUI() {
        title = "Find Friends"
        view.backgroundColor = backgroundColor

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissSearch)
        )

        searchBar.placeholder = "Search by username or name"
        searchBar.delegate = self
        searchBar.searchTextField.backgroundColor = searchBarBackgroundColor
        searchBar.tintColor = accentColor
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = backgroundColor
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
        label.textColor = textSecondaryColor
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
        let isSearchBarEmpty = searchBar.text?.isEmpty ?? true
        emptyStateView.isHidden = isSearching || !searchResults.isEmpty || !isSearchBarEmpty
    }

    private func searchUsers(with query: String) {
        isSearching = true
        activityIndicator.startAnimating()
        updateEmptyStateVisibility()

        let db = Firestore.firestore()

        guard let currentUserId = Auth.auth().currentUser?.uid else { // Use Firebase Auth current user
            print("Warning: Could not get current user ID")
            self.isSearching = false
            self.activityIndicator.stopAnimating()
            self.searchResults = []
            self.tableView.reloadData()
            self.updateEmptyStateVisibility()
            return
        }

        db.collection("users")
            .limit(to: 50)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                self.isSearching = false

                if let error = error {
                    print("Error searching for users: \(error.localizedDescription)")
                    self.searchResults = []
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                    self.updateEmptyStateVisibility()
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.searchResults = []
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                    self.updateEmptyStateVisibility()
                    return
                }

                // Update compactMap to include profileColor
                let allUsers = documents.compactMap { doc -> (username: String, name: String, userId: String, profileColor: String)? in
                    let data = doc.data()
                    let username = data["username"] as? String ?? "user"
                    let name = data["name"] as? String ?? "Unknown"
                    let userId = doc.documentID
                    let profileColor = data["profileColor"] as? String ?? "#4CBB7B"
                    
                    if userId == currentUserId {
                        return nil // Exclude current user
                    }

                    return (username: username, name: name, userId: userId, profileColor: profileColor)
                }

                var excludedUserIds = Set<String>()

                let group = DispatchGroup()

                group.enter()
                db.collection("friendRequests")
                    .whereField("fromUserId", isEqualTo: currentUserId)
                    .whereField("status", in: ["pending", "accepted"])
                    .getDocuments { fromSnapshot, error in
                        if let documents = fromSnapshot?.documents {
                            for doc in documents {
                                if let toUserId = doc.data()["toUserId"] as? String {
                                    excludedUserIds.insert(toUserId)
                                }
                            }
                        } else if let error = error {
                            print("Error fetching sent friend requests: \(error.localizedDescription)")
                        }
                        group.leave()
                    }

                group.enter()
                db.collection("friendRequests")
                    .whereField("toUserId", isEqualTo: currentUserId)
                    .whereField("status", in: ["pending", "accepted"])
                    .getDocuments { toSnapshot, error in
                        if let documents = toSnapshot?.documents {
                            for doc in documents {
                                if let fromUserId = doc.data()["fromUserId"] as? String {
                                    excludedUserIds.insert(fromUserId)
                                }
                            }
                        } else if let error = error {
                            print("Error fetching received friend requests: \(error.localizedDescription)")
                        }
                        group.leave()
                    }

                group.notify(queue: .main) {
                    let filteredUsers = allUsers.filter { !excludedUserIds.contains($0.userId) }

                if !query.isEmpty {
                    let lowercaseQuery = query.lowercased()
                    self.searchResults = filteredUsers.filter {
                        $0.name.lowercased().contains(lowercaseQuery) ||
                        $0.username.lowercased().contains(lowercaseQuery)
                    }.sorted { $0.name.lowercased() < $1.name.lowercased() }
                } else {
                    self.searchResults = filteredUsers.sorted { $0.name.lowercased() < $1.name.lowercased() }
                }

                    self.activityIndicator.stopAnimating()
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

        guard let currentUserId = Auth.auth().currentUser?.uid else { // Use Firebase Auth current user
            showError(message: "You need to be logged in to add friends")
            return
        }

        if currentUserId == userId {
            showError(message: "Cannot send friend request to yourself.")
            return
        }

        let db = Firestore.firestore()

        // Check if a request already exists (either way) or if they are already friends
        let group = DispatchGroup()
        var relationshipExists = false

        // Check: Current user sent request to target user (pending or accepted)
        group.enter()
        db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: currentUserId)
            .whereField("toUserId", isEqualTo: userId)
            .limit(to: 1) // Limit to 1 as we only need to know if *any* exist
            .getDocuments { snapshot, error in
                if let count = snapshot?.count, count > 0 {
                    relationshipExists = true
                    print("Relationship found: Current user -> Target user")
                }
                group.leave()
            }

        // Check: Target user sent request to current user (pending or accepted)
        group.enter()
        db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: userId)
            .whereField("toUserId", isEqualTo: currentUserId)
            .limit(to: 1) // Limit to 1
            .getDocuments { snapshot, error in
                if let count = snapshot?.count, count > 0 {
                    relationshipExists = true
                     print("Relationship found: Target user -> Current user")
                }
                group.leave()
            }


        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            if relationshipExists {
                self.showError(message: "Friend request already sent or you are already friends.")
                // Optionally re-enable the button on the specific cell if needed
                if let index = self.searchResults.firstIndex(where: { $0.userId == userId }),
                   let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SearchResultCell {
                    cell.resetButtonState()
                }
                return
            }

            // If no relationship exists, proceed to send request
            let requestData: [String: Any] = [
                "fromUserId": currentUserId,
                "toUserId": userId,
                "status": "pending",
                "timestamp": FieldValue.serverTimestamp()
            ]

            db.collection("friendRequests").addDocument(data: requestData) { error in
                if let error = error {
                    self.showError(message: "Error sending friend request: \(error.localizedDescription)")
                     // Re-enable button on error
                     if let index = self.searchResults.firstIndex(where: { $0.userId == userId }),
                        let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SearchResultCell {
                         cell.resetButtonState()
                     }
                    return
                }

                self.showSuccessMessage(username: username)
                // Remove user from search results immediately after sending request
                self.searchResults.removeAll { $0.userId == userId }
                self.tableView.reloadData()
                self.updateEmptyStateVisibility()
            }
        }
    }


    private func showSuccessMessage(username: String) {
        let successView = UIView()
        successView.backgroundColor = accentColor
        successView.alpha = 0
        successView.layer.cornerRadius = 8
        successView.translatesAutoresizingMaskIntoConstraints = false
        // Add to the key window to overlay everything
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        window.addSubview(successView)


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
            // Position relative to window edges
            successView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            successView.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -30), // Adjust spacing as needed
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
            successView.transform = CGAffineTransform(translationX: 0, y: -10) // Slight upward animation
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
                successView.alpha = 0
                 successView.transform = .identity // Return to original position
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

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchUsers(with: "")
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
        // Pass the profileColor to the configure method
        cell.configure(username: result.username,
                       name: result.name,
                       profileColorHex: result.profileColor,
                       accentColor: accentColor)


        cell.onAddFriend = { [weak self] in
            self?.sendFriendRequest(to: result.userId, username: result.username)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Search Result Cell
class SearchResultCell: UITableViewCell {

    private let avatarView = UIView()
    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private let separator = UIView()
    private let defaultAvatarColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)

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
        backgroundColor = .white // Use the controller's background constant if needed

        contentView.backgroundColor = .white // Use the controller's cell background constant if needed

        avatarView.backgroundColor = defaultAvatarColor // Start with default
        avatarView.layer.cornerRadius = 25
        avatarView.clipsToBounds = true // Ensure label doesn't go outside
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarView)

        avatarLabel.font = UIFont(name: "Sen-Bold", size: 18)
        avatarLabel.textColor = .white
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(avatarLabel)

        nameLabel.font = UIFont(name: "Sen-Bold", size: 16)
        nameLabel.textColor = .black // Use controller's text primary color constant
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        usernameLabel.font = UIFont(name: "Sen-Regular", size: 14)
        usernameLabel.textColor = .darkGray // Use controller's text secondary color constant
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(usernameLabel)

        addButton.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
        addButton.backgroundColor = .clear
        addButton.layer.cornerRadius = 15
        addButton.layer.borderWidth = 1.5
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addButton)

        separator.backgroundColor = UIColor(white: 0.9, alpha: 1.0) // Use controller's separator color constant
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)

        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),

            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: addButton.leadingAnchor, constant: -12), // Use lessThanOrEqualTo

            usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 30), // Ensure button is tappable
            addButton.heightAnchor.constraint(equalToConstant: 30),

            separator.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

   // In SearchResultCell class, update the configure method
    func configure(username: String, name: String, profileColorHex: String, accentColor: UIColor) {
        nameLabel.text = name
        usernameLabel.text = "@\(username)"

        avatarLabel.text = String(name.first ?? username.first ?? "?").uppercased()

        // Use accentColor as fallback instead of defaultAvatarColor
        avatarView.backgroundColor = UIColor.fromHex(profileColorHex) ?? accentColor

        // Use the passed accentColor for the button
        addButton.tintColor = accentColor
        addButton.layer.borderColor = accentColor.cgColor

        // Reset button state visually
        resetButtonState()
    }


    @objc private func addButtonTapped() {
        // Disable button visually immediately
        addButton.isEnabled = false
        addButton.alpha = 0.5
        addButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        // Call the closure to handle the logic (which might re-enable on error)
        onAddFriend?()
         // Animate back slightly for feedback, but keep it disabled
        UIView.animate(withDuration: 0.1, delay: 0.1, options: []) {
             self.addButton.transform = .identity
         }

    }

    // Add a method to reset the button's appearance if needed (e.g., on error)
    func resetButtonState() {
        addButton.isEnabled = true
        addButton.alpha = 1.0
        addButton.transform = .identity
        addButton.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
    }


    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        usernameLabel.text = nil
        avatarLabel.text = nil
        onAddFriend = nil
        avatarView.backgroundColor = defaultAvatarColor // Reset to default color
        resetButtonState() // Reset button appearance
    }
}