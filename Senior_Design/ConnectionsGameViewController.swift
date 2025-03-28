import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

class ConnectionsGameViewController: UIViewController {
    
    // MARK: - Properties
    
    let gridSize = 4
    var selectedButtons: Set<UIButton> = []
    var attemptsLeft = 4
    let totalAttempts = 4
    var gameTimer: Timer?
    var remainingTime = 120
    var completedCategories: Set<String> = []
    var buttonCategories: [Int: String] = [:]
    var buttonImages: [Int: String] = [:]
    
    // MARK: - Theme Colors
    
    private enum Theme {
        static let backgroundColor = UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1.0)
        static let cardColor = UIColor.white
        static let primaryText = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1.0)
        static let secondaryText = UIColor(red: 100/255, green: 100/255, blue: 110/255, alpha: 1.0)
        static let accentColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
        static let selectionColor = UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0)
        
        static let categoryColors: [String: UIColor] = [
            "compost": UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0),
            "recycle": UIColor(red: 87/255, green: 155/255, blue: 252/255, alpha: 1.0),
            "hazard": UIColor(red: 255/255, green: 184/255, blue: 76/255, alpha: 1.0),
            "landfill": UIColor(red: 163/255, green: 126/255, blue: 73/255, alpha: 1.0)
        ]
    }
    
    let objectDescriptions: [String: String] = [
        "recycle1": "Paper",
        "recycle2": "Water Bottle",
        "recycle3": "Card board",
        "recycle4": "Glass Bottle",
        "landfill1": "Plastic Bag",
        "landfill2": "Container",
        "landfill3": "Plastic Straws",
        "landfill4": "Plastic Utensils",
        "compost1": "Apple",
        "compost2": "Egg Shells",
        "compost3": "Broccoli",
        "compost4": "Bread",
        "hazard1": "Battery",
        "hazard2": "Light Bulb",
        "hazard3": "Paint",
        "hazard4": "Pesticide"
    ]
    
    let categories: [String: [String]] = [
        "recycle": ["recycle1", "recycle2", "recycle3", "recycle4"],
        "landfill": ["landfill1", "landfill2", "landfill3", "landfill4"],
        "compost": ["compost1", "compost2", "compost3", "compost4"],
        "hazard": ["hazard1", "hazard2", "hazard3", "hazard4"]
    ]
    
    // MARK: - UI Elements
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 1
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Connections"
        label.font = UIFont(name: "Sen-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = Theme.primaryText
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Group items by waste category"
        label.font = UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        label.textColor = Theme.secondaryText
        label.textAlignment = .center
        return label
    }()
    
    private let timerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 1
        return view
    }()
    
    private let timerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "clock.fill")
        imageView.tintColor = Theme.accentColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "2:00"
        label.font = UIFont(name: "Sen-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = Theme.primaryText
        label.textAlignment = .left
        return label
    }()
    
    private let helpButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        button.setImage(UIImage(systemName: "questionmark.circle.fill", withConfiguration: config), for: .normal)
        button.tintColor = Theme.accentColor
        button.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let gridContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let attemptsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 1
        return view
    }()
    
    private let attemptsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Attempts"
        label.font = UIFont(name: "Sen-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = Theme.primaryText
        label.textAlignment = .center
        return label
    }()
    
    private let attemptsDotsView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let restartButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Restart Game", for: .normal)
        button.titleLabel?.font = UIFont(name: "Sen-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Theme.accentColor
        button.layer.cornerRadius = 20
        button.layer.shadowColor = Theme.accentColor.withAlphaComponent(0.4).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 1
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGrid()
        updateAttemptsDots()
        startTimer()
        
        navigationController?.navigationBar.tintColor = Theme.accentColor
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        headerView.backgroundColor = .clear
        headerView.layer.shadowOpacity = 0
        attemptsContainerView.backgroundColor = .clear
        attemptsContainerView.layer.shadowOpacity = 0
    }
        
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = Theme.backgroundColor
        
        setupHeader()
        setupTimerView()
        setupGridContainer()
        setupAttemptsIndicator()
        setupRestartButton()
    }
    
    private func setupHeader() {
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
        ])
    }
    
    private func setupTimerView() {
        view.addSubview(timerView)
        timerView.addSubview(timerImageView)
        timerView.addSubview(timerLabel)
        view.addSubview(helpButton)
        
        NSLayoutConstraint.activate([
            timerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            timerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timerView.widthAnchor.constraint(equalToConstant: 100),
            timerView.heightAnchor.constraint(equalToConstant: 40),
            
            timerImageView.leadingAnchor.constraint(equalTo: timerView.leadingAnchor, constant: 12),
            timerImageView.centerYAnchor.constraint(equalTo: timerView.centerYAnchor),
            timerImageView.widthAnchor.constraint(equalToConstant: 20),
            timerImageView.heightAnchor.constraint(equalToConstant: 20),
            
            timerLabel.leadingAnchor.constraint(equalTo: timerImageView.trailingAnchor, constant: 8),
            timerLabel.centerYAnchor.constraint(equalTo: timerView.centerYAnchor),
            
            helpButton.centerYAnchor.constraint(equalTo: timerView.centerYAnchor),
            helpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            helpButton.widthAnchor.constraint(equalToConstant: 40),
            helpButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
    }
    
    private func setupGridContainer() {
        view.addSubview(gridContainerView)
        
        NSLayoutConstraint.activate([
            gridContainerView.topAnchor.constraint(equalTo: timerView.bottomAnchor, constant: 16),
            gridContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            gridContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            gridContainerView.heightAnchor.constraint(equalTo: gridContainerView.widthAnchor)
        ])
    }
    
    private func setupAttemptsIndicator() {
        view.addSubview(attemptsContainerView)
        attemptsContainerView.addSubview(attemptsLabel)
        attemptsContainerView.addSubview(attemptsDotsView)
        
        for _ in 0..<totalAttempts {
            let dotView = UIView()
            dotView.backgroundColor = Theme.accentColor.withAlphaComponent(0.3)
            dotView.layer.cornerRadius = 6
            dotView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                dotView.widthAnchor.constraint(equalToConstant: 12),
                dotView.heightAnchor.constraint(equalToConstant: 12)
            ])
            
            attemptsDotsView.addArrangedSubview(dotView)
        }
        
        NSLayoutConstraint.activate([
            attemptsContainerView.topAnchor.constraint(equalTo: gridContainerView.bottomAnchor, constant: 16),
            attemptsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            attemptsContainerView.widthAnchor.constraint(equalToConstant: 160),
            attemptsContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            attemptsLabel.topAnchor.constraint(equalTo: attemptsContainerView.topAnchor, constant: 10),
            attemptsLabel.centerXAnchor.constraint(equalTo: attemptsContainerView.centerXAnchor),
            
            attemptsDotsView.topAnchor.constraint(equalTo: attemptsLabel.bottomAnchor, constant: 6),
            attemptsDotsView.centerXAnchor.constraint(equalTo: attemptsContainerView.centerXAnchor),
        ])
    }
    
    private func setupRestartButton() {
        view.addSubview(restartButton)
        
        NSLayoutConstraint.activate([
            restartButton.topAnchor.constraint(equalTo: attemptsContainerView.bottomAnchor, constant: 10),
            restartButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restartButton.widthAnchor.constraint(equalToConstant: 180),
            restartButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        restartButton.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
    }
    
    private func setupGrid() {
        let containerSize = gridContainerView.frame.width > 0 ? gridContainerView.frame.width : view.frame.width - 40
        let spacing: CGFloat = 8
        let buttonSize = (containerSize - (spacing * CGFloat(gridSize - 1))) / CGFloat(gridSize)
        
        var categoryImages = generateCategoryImages()
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let button = createButton()
                let xPos = CGFloat(col) * (buttonSize + spacing)
                let yPos = CGFloat(row) * (buttonSize + spacing)
                
                button.frame = CGRect(
                    x: xPos,
                    y: yPos,
                    width: buttonSize,
                    height: buttonSize
                )
                
                let tag = row * gridSize + col
                button.tag = tag
                
                if let (category, image) = categoryImages.popLast() {
                    button.setImage(UIImage(named: image), for: .normal)
                    buttonCategories[tag] = category
                    buttonImages[tag] = image
                }
                
                gridContainerView.addSubview(button)
            }
        }
    }
    
    private func createButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = Theme.cardColor
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.tintColor = .clear
        button.imageView?.contentMode = .scaleAspectFit
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)

        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 1
        button.layer.masksToBounds = false
        
        button.addTarget(self, action: #selector(tileTapped(_:)), for: .touchUpInside)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        button.addGestureRecognizer(longPress)
        
        return button
    }
    
    // MARK: - Game Logic
    
    @objc private func tileTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if selectedButtons.contains(sender) {
            UIView.animate(withDuration: 0.2) {
                sender.backgroundColor = Theme.cardColor
                sender.transform = .identity
            }
            selectedButtons.remove(sender)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                sender.backgroundColor = Theme.selectionColor
                sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            })
            selectedButtons.insert(sender)
        }
        
        if selectedButtons.count == 4 {
            checkForConnection()
        } else if selectedButtons.count > 1 {
            checkForMismatch()
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let button = gesture.view as? UIButton else { return }
        
        if gesture.state == .began {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            UIView.transition(with: button, duration: 0.3, options: .transitionFlipFromLeft, animations: {
                button.setImage(nil, for: .normal)
                if let imageName = self.buttonImages[button.tag],
                   let originalDescription = self.objectDescriptions[imageName] {
                    let words = originalDescription.split(separator: " ")
                    let finalDescription: String
                    if words.count == 2 {
                        finalDescription = words.joined(separator: "\n")
                    } else {
                        finalDescription = originalDescription
                    }
                    button.setTitle(finalDescription, for: .normal)
                    button.setTitleColor(.black, for: .normal)
                }
            }, completion: nil)
        } else if gesture.state == .ended || gesture.state == .cancelled {
            UIView.transition(with: button, duration: 0.3, options: .transitionFlipFromRight, animations: {
                button.setTitle("", for: .normal)
                if let imageName = self.buttonImages[button.tag] {
                    button.setImage(UIImage(named: imageName), for: .normal)
                }
            }, completion: nil)
        }
    }
    
    private func generateCategoryImages() -> [(String, String)] {
        var images: [(String, String)] = []
        for (category, imageNames) in categories {
            for image in imageNames {
                images.append((category, image))
            }
        }
        return images.shuffled()
    }
    
    private func checkForMismatch() {
        let categoriesSet = Set(selectedButtons.compactMap { buttonCategories[$0.tag] })
        if categoriesSet.count > 1 {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            showMismatchAlert()
            decrementAttempts()
            resetSelections()
        }
    }
    
    private func checkForConnection() {
        guard selectedButtons.count == 4 else { return }
        
        let firstCategory = buttonCategories[selectedButtons.first!.tag]
        let allSameCategory = selectedButtons.allSatisfy { buttonCategories[$0.tag] == firstCategory }
        
        if allSameCategory {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            completedCategories.insert(firstCategory!)
            applyBorderColor(for: firstCategory!)
            disableButtons()
            selectedButtons.removeAll()
            
            if completedCategories.count == categories.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showWinAlert()
                }
            }
        } else {
            decrementAttempts()
            resetSelections()
        }
    }
    
    private func applyBorderColor(for category: String?) {
        guard let category = category else { return }
        
        let borderColor = Theme.categoryColors[category] ?? Theme.accentColor
        
        selectedButtons.forEach { button in
            button.layer.borderWidth = 4
            button.layer.borderColor = borderColor.cgColor
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
                button.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                button.backgroundColor = borderColor.withAlphaComponent(0.3)
            }) { _ in
                UIView.animate(withDuration: 0.3) {
                    button.transform = .identity
                }
            }
        }
    }
    
    private func disableButtons() {
        selectedButtons.forEach { button in
            button.isEnabled = false
            button.alpha = 0.9
        }
    }
    
    private func decrementAttempts() {
        attemptsLeft -= 1
        updateAttemptsDots()
        
        if attemptsLeft == 0 {
            if let currentAlert = presentedViewController as? UIAlertController {
                currentAlert.dismiss(animated: true) { [weak self] in
                    self?.showGameOverAlert(reason: "You've used all your attempts!")
                }
            } else {
                showGameOverAlert(reason: "You've used all your attempts!")
            }
        }
    }
    
    private func updateAttemptsDots() {
        for (index, view) in attemptsDotsView.arrangedSubviews.enumerated() {
            UIView.animate(withDuration: 0.3) {
                if index < self.attemptsLeft {
                    view.backgroundColor = Theme.accentColor
                    view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                } else {
                    view.backgroundColor = Theme.accentColor.withAlphaComponent(0.3)
                    view.transform = .identity
                }
            }
        }
    }
    
    private func resetSelections() {
        selectedButtons.forEach { button in
            UIView.animate(withDuration: 0.3) {
                button.backgroundColor = Theme.cardColor
                button.transform = .identity
                button.layer.borderWidth = 0
            }
        }
        selectedButtons.removeAll()
    }
    
    // MARK: - Timer Methods
    
    private func startTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer() {
        if remainingTime > 0 {
            remainingTime -= 1
            let minutes = remainingTime / 60
            let seconds = remainingTime % 60
            timerLabel.text = String(format: "%d:%02d", minutes, seconds)
            
            if remainingTime <= 30 {
                UIView.animate(withDuration: 0.5, animations: {
                    self.timerLabel.textColor = UIColor.red
                })
                
                if remainingTime <= 10 {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.timerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    }) { _ in
                        UIView.animate(withDuration: 0.3) {
                            self.timerView.transform = .identity
                        }
                    }
                }
            }
        } else {
            gameTimer?.invalidate()
            showGameOverAlert(reason: "Time's up!")
        }
    }
    
    // MARK: - Game State Alerts
    
    private func showMismatchAlert() {
        let alert = UIAlertController(
            title: "Mismatch!",
            message: "The selected tiles are not from the same category. Try again!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showWinAlert() {
        gameTimer?.invalidate()
        updateUserScore(10)
        
        let alert = UIAlertController(
            title: "You Win! 🎉",
            message: "Congratulations! You matched all the groups correctly!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Play Again", style: .default) { _ in self.resetGame() })
        present(alert, animated: true)
    }
    
    private func showGameOverAlert(reason: String) {
        gameTimer?.invalidate()
        
        let alert = UIAlertController(
            title: "Game Over",
            message: reason,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { _ in self.resetGame() })
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func helpButtonTapped() {
        gameTimer?.invalidate()
        
        let alert = UIAlertController(
            title: "How to Play",
            message: "Find groups of 4 items that belong to the same waste category.\n\n• Long press on a tile to see what it is\n• Select 4 tiles of the same category to form a group\n• You have 4 attempts to find all groups",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Got it", style: .default) { _ in
            self.startTimer()
        })
        present(alert, animated: true)
    }
    
    @objc private func restartGame() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.restartButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.restartButton.transform = .identity
            }
        }
        
        gameTimer?.invalidate()
        resetGame()
    }
    
    // MARK: - Game Reset
    
    private func resetGame() {
        completedCategories.removeAll()
        selectedButtons.removeAll()
        buttonCategories.removeAll()
        buttonImages.removeAll()
        attemptsLeft = totalAttempts
        remainingTime = 120
        
        timerLabel.textColor = Theme.primaryText
        
        for subview in gridContainerView.subviews {
            UIView.animate(withDuration: 0.3, animations: {
                subview.alpha = 0
            }) { _ in
                subview.removeFromSuperview()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.setupGrid()
            self.updateAttemptsDots()
            self.timerLabel.text = "2:00"
            self.startTimer()
            
            self.gridContainerView.subviews.forEach { $0.alpha = 0 }
            UIView.animate(withDuration: 0.5) {
                self.gridContainerView.subviews.forEach { $0.alpha = 1 }
            }
        }
    }
    
    // MARK: - Firebase
    
    private func updateUserScore(_ score: Int) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(user.uid)
        
        UserDefaults.standard.set(true, forKey: "game_0_completed")
        
        userDoc.updateData([
            "score": FieldValue.increment(Int64(score))
        ]) { error in
            if let error = error {
                print("Error updating score: \(error.localizedDescription)")
            } else {
                print("Score successfully updated!")
            }
        }
    }
}