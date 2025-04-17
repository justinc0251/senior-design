import UIKit
import FirebaseFirestore
import FirebaseAuth

// MARK: - Friend Requests View Controller
class FriendRequestsViewController: UIViewController {
    
    private let tableView = UITableView()
    private let emptyStateView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    var accentColor: UIColor = .systemBlue
    private var friendRequests: [(userId: String, username: String, name: String, requestId: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchFriendRequests()
    }
    
    private func setupUI() {
        title = "Friend Requests"
        view.backgroundColor = .white
        
        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(FriendRequestCell.self, forCellReuseIdentifier: "FriendRequestCell")
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
        
        let imageView = UIImageView(image: UIImage(systemName: "person.2.slash"))
        imageView.tintColor = UIColor(white: 0.8, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(imageView)
        
        let label = UILabel()
        label.text = "No pending friend requests"
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
        emptyStateView.isHidden = !friendRequests.isEmpty
    }
    
    private func fetchFriendRequests() {
        guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else {
            return
        }
        
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("friendRequests")
            .whereField("toUserId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: "pending")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    print("Error fetching friend requests: \(error.localizedDescription)")
                    return
                }
                
                var tempRequests: [(userId: String, username: String, name: String, requestId: String)] = []
                let group = DispatchGroup()
                
                for document in snapshot?.documents ?? [] {
                    let data = document.data()
                    if let fromUserId = data["fromUserId"] as? String {
                        group.enter()
                        
                        // Fetch user info for each request
                        db.collection("users").document(fromUserId).getDocument { userSnapshot, error in
                            defer { group.leave() }
                            
                            if let userData = userSnapshot?.data() {
                                let username = userData["username"] as? String ?? "user"
                                let name = userData["name"] as? String ?? "User"
                                
                                tempRequests.append((
                                    userId: fromUserId,
                                    username: username,
                                    name: name,
                                    requestId: document.documentID
                                ))
                            }
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    self.friendRequests = tempRequests
                    self.tableView.reloadData()
                    self.updateEmptyStateVisibility()
                }
            }
    }
    
    private func handleRequestAction(index: Int, accept: Bool) {
        guard index < friendRequests.count else { return }
        
        let request = friendRequests[index]
        let db = Firestore.firestore()
        let requestRef = db.collection("friendRequests").document(request.requestId)
        
        if accept {
            // Accept the request - update status to accepted
            requestRef.updateData([
                "status": "accepted"
            ]) { [weak self] error in
                if let error = error {
                    print("Error accepting request: \(error.localizedDescription)")
                    return
                }
                
                // Create mutual following relationship
                self?.createMutualFollowing(fromUserId: request.userId, toUserId: Auth.auth().currentUser?.uid ?? "")
                
                // Remove from the list
                self?.friendRequests.remove(at: index)
                self?.tableView.reloadData()
                self?.updateEmptyStateVisibility()
                
                // Show success toast
                self?.showToast(message: "Friend request accepted!")
            }
        } else {
            // Decline the request - update status to declined
            requestRef.updateData([
                "status": "declined"
            ]) { [weak self] error in
                if let error = error {
                    print("Error declining request: \(error.localizedDescription)")
                    return
                }
                
                // Remove from the list
                self?.friendRequests.remove(at: index)
                self?.tableView.reloadData()
                self?.updateEmptyStateVisibility()
            }
        }
    }

    private func createMutualFollowing(fromUserId: String, toUserId: String) {
        guard !fromUserId.isEmpty && !toUserId.isEmpty else { return }
        
        let db = Firestore.firestore()
        
        // Check if reverse relationship already exists
        db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: toUserId)
            .whereField("toUserId", isEqualTo: fromUserId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error checking reverse relationship: \(error.localizedDescription)")
                    return
                }
                
                // If reverse relationship doesn't exist, create it
                if snapshot?.documents.isEmpty ?? true {
                    // Create a friend request from current user to the other user with accepted status
                    let reverseRequestData: [String: Any] = [
                        "fromUserId": toUserId,
                        "toUserId": fromUserId,
                        "status": "accepted",
                        "timestamp": FieldValue.serverTimestamp()
                    ]
                    
                    db.collection("friendRequests").addDocument(data: reverseRequestData) { error in
                        if let error = error {
                            print("Error creating reverse following: \(error.localizedDescription)")
                        } else {
                            print("Successfully created mutual following relationship")
                        }
                    }
                } else {
                    if let doc = snapshot?.documents.first {
                        let data = doc.data()
                        if (data["status"] as? String) == "pending" {
                            db.collection("friendRequests").document(doc.documentID).updateData([
                                "status": "accepted"
                            ]) { error in
                                if let error = error {
                                    print("Error updating reverse request: \(error.localizedDescription)")
                                } else {
                                    print("Successfully updated reverse request to accepted")
                                }
                            }
                        }
                    }
                }
            }
    }
    
    private func showToast(message: String) {
        let toastView = UIView()
        toastView.backgroundColor = accentColor
        toastView.alpha = 0
        toastView.layer.cornerRadius = 8
        toastView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastView)
        
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = UIFont(name: "Sen-Regular", size: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        toastView.addSubview(label)
        
        NSLayoutConstraint.activate([
            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            toastView.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            toastView.heightAnchor.constraint(equalToConstant: 44),
            
            label.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: toastView.centerYAnchor)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toastView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
                toastView.alpha = 0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        })
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource for Friend Requests
extension FriendRequestsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as? FriendRequestCell else {
            return UITableViewCell()
        }
        
        let request = friendRequests[indexPath.row]
        cell.configure(username: request.username, name: request.name, accentColor: accentColor)
        
        cell.onAccept = { [weak self] in
            self?.handleRequestAction(index: indexPath.row, accept: true)
        }
        
        cell.onDecline = { [weak self] in
            self?.handleRequestAction(index: indexPath.row, accept: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - Friend Request Cell
class FriendRequestCell: UITableViewCell {
    
    private let avatarView = UIView()
    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let acceptButton = UIButton(type: .system)
    private let declineButton = UIButton(type: .system)
    
    var onAccept: (() -> Void)?
    var onDecline: (() -> Void)?
    
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
        
        // Accept Button
        acceptButton.setTitle("Accept", for: .normal)
        acceptButton.backgroundColor = .clear
        acceptButton.layer.cornerRadius = 15
        acceptButton.layer.borderWidth = 1
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(acceptButton)
        
        // Decline Button
        declineButton.setTitle("Decline", for: .normal)
        declineButton.backgroundColor = .clear
        declineButton.layer.cornerRadius = 15
        declineButton.layer.borderWidth = 1
        declineButton.addTarget(self, action: #selector(declineButtonTapped), for: .touchUpInside)
        declineButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(declineButton)
        
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            usernameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            acceptButton.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            acceptButton.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            acceptButton.widthAnchor.constraint(equalToConstant: 80),
            acceptButton.heightAnchor.constraint(equalToConstant: 30),
            
            declineButton.leadingAnchor.constraint(equalTo: acceptButton.trailingAnchor, constant: 8),
            declineButton.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            declineButton.widthAnchor.constraint(equalToConstant: 80),
            declineButton.heightAnchor.constraint(equalToConstant: 30)
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
        
        acceptButton.tintColor = accentColor
        acceptButton.layer.borderColor = accentColor.cgColor
        
        declineButton.tintColor = UIColor.systemRed
        declineButton.layer.borderColor = UIColor.systemRed.cgColor
    }
    
    @objc private func acceptButtonTapped() {
        onAccept?()
        
        // Provide visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.acceptButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.acceptButton.transform = .identity
            }
        })
    }
    
    @objc private func declineButtonTapped() {
        onDecline?()
        
        // Provide visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.declineButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.declineButton.transform = .identity
            }
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        usernameLabel.text = nil
        avatarLabel.text = nil
        onAccept = nil
        onDecline = nil
    }
}