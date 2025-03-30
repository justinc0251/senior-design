import UIKit
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private var profileImageView: UIImageView!
    private var nameLabel: UILabel!
    private var usernameLabel: UILabel!
    private var joinDateLabel: UILabel!
    
    private var statsContainerView: UIView!
    private var followingContainer: UIView!
    private var followersContainer: UIView!
    
    private var addFriendsButton: UIButton!
    private var shareButton: UIButton!
    
    private let accentColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
    private let secondaryColor = UIColor(red: 87/255, green: 155/255, blue: 252/255, alpha: 1.0)
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        setupUI()
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
        navigationItem.rightBarButtonItem = settingsButton
        
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = accentColor
    }
    
    private func setupUI() {
        setupProfileHeader()
        setupStatsView()
        setupActionButtons()
        setupConstraints()
    }
    
    private func setupProfileHeader() {
        profileImageView = UIImageView()
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
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
        
        nameLabel = UILabel()
        nameLabel.text = "Justin Chung"
        nameLabel.font = UIFont(name: "Sen-Regular", size: 28)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        usernameLabel = UILabel()
        usernameLabel.text = "@jastinc4"
        usernameLabel.font = UIFont(name: "Sen-Regular", size: 16)
        usernameLabel.textColor = .darkGray
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameLabel)
        
        joinDateLabel = UILabel()
        joinDateLabel.text = "• Joined Mar 2025"
        joinDateLabel.font = UIFont(name: "Sen-Regular", size: 16)
        joinDateLabel.textColor = .darkGray
        joinDateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(joinDateLabel)
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
        
        followingContainer = createStatContainer(title: "2", subtitle: "Following")
        statsContainerView.addSubview(followingContainer)
        
        let separator = UIView()
        separator.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        separator.translatesAutoresizingMaskIntoConstraints = false
        statsContainerView.addSubview(separator)
        
        followersContainer = createStatContainer(title: "4", subtitle: "Followers")
        statsContainerView.addSubview(followersContainer)
        
        NSLayoutConstraint.activate([
            followingContainer.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor),
            followingContainer.topAnchor.constraint(equalTo: statsContainerView.topAnchor),
            followingContainer.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor),
            followingContainer.widthAnchor.constraint(equalTo: statsContainerView.widthAnchor, multiplier: 0.5),
            
            separator.centerXAnchor.constraint(equalTo: statsContainerView.centerXAnchor),
            separator.topAnchor.constraint(equalTo: statsContainerView.topAnchor, constant: 15),
            separator.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: -15),
            separator.widthAnchor.constraint(equalToConstant: 1),
            
            followersContainer.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor),
            followersContainer.topAnchor.constraint(equalTo: statsContainerView.topAnchor),
            followersContainer.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor),
            followersContainer.widthAnchor.constraint(equalTo: statsContainerView.widthAnchor, multiplier: 0.5)
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
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 15),
            
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
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
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
    
    @objc private func handleEditProfile() {
        let alertController = UIAlertController(title: "Edit Profile", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Name"
            textField.text = self.nameLabel.text
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Username"
            textField.text = self.usernameLabel.text
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let nameText = alertController.textFields?[0].text, !nameText.isEmpty {
                self.nameLabel.text = nameText
            }
            if let usernameText = alertController.textFields?[1].text, !usernameText.isEmpty {
                self.usernameLabel.text = usernameText
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func handleLogout() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            let loginVC = LoginViewController()
            let nav = UINavigationController(rootViewController: loginVC)
            sceneDelegate.window?.rootViewController = nav
        }
    }
    
    @objc private func handleAddFriends() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let searchVC = ModernUserSearchViewController()
        searchVC.accentColor = secondaryColor
        let nav = UINavigationController(rootViewController: searchVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    @objc private func handleShare() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let items = ["Check out my waste learning progress!"]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityController, animated: true)
    }
}

// MARK: - Modern User Search
class ModernUserSearchViewController: UIViewController {
    
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
        
        // Search Bar
        searchBar.placeholder = "Search by username or name"
        searchBar.delegate = self
        searchBar.searchTextField.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        searchBar.tintColor = accentColor
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: "SearchResultCell")
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
        guard !query.isEmpty else {
            searchResults = []
            tableView.reloadData()
            updateEmptyStateVisibility()
            return
        }
        
        isSearching = true
        activityIndicator.startAnimating()
        updateEmptyStateVisibility()
        
        // Get reference to Firestore
        let db = Firestore.firestore()
        
        // Search users where username or name contains the query
        let lowercaseQuery = query.lowercased()
        
        db.collection("users")
            .whereField("searchTerms", arrayContains: lowercaseQuery)
            .limit(to: 20)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isSearching = false
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    print("Error searching for users: \(error.localizedDescription)")
                    self.searchResults = []
                } else if let documents = snapshot?.documents, !documents.isEmpty {
                    // Map Firestore documents to searchResults format
                    self.searchResults = documents.compactMap { doc -> (username: String, name: String, userId: String)? in
                        let data = doc.data()
                        guard let username = data["username"] as? String,
                              let name = data["name"] as? String else {
                            return nil
                        }
                        return (username: username, name: name, userId: doc.documentID)
                    }
                } else {
                    self.searchResults = []
                }
                
                self.tableView.reloadData()
                self.updateEmptyStateVisibility()
            }
    }
    
    @objc private func dismissSearch() {
        dismiss(animated: true)
    }
    
    private func sendFriendRequest(to userId: String, username: String) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Get current user ID
        guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else {
            showError(message: "You need to be logged in to add friends")
            return
        }
        
        let db = Firestore.firestore()
        
        // Create friend request document
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
            
            // Show success message
            self?.showSuccessMessage(username: username)
        }
    }
    
    private func showSuccessMessage(username: String) {
        // Show success toast
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
extension ModernUserSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchUsers(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ModernUserSearchViewController: UITableViewDelegate, UITableViewDataSource {
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
        
        // Add Button
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
        addButton.tintColor = accentColor
        addButton.layer.borderColor = accentColor.cgColor
    }
    
    @objc private func addButtonTapped() {
        onAddFriend?()
        
        // Provide visual feedback
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