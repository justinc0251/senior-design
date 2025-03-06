import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

class ConnectionsGameViewController: UIViewController {
    
    let gridSize = 4
    var selectedButtons: Set<UIButton> = []
    var attemptsLeft = 4
    let totalAttempts = 4
    var gameTimer: Timer?
    var remainingTime = 120
    var completedCategories: Set<String> = []
    var buttonCategories: [Int: String] = [:]
    var buttonImages: [Int: String] = [:]
    
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
    
    // MARK: - Attempts Indicator UI
    
    private let attemptsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Attempts:"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private var attemptsDots: [UILabel] = []
    private let attemptsDotsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()
    
    private let attemptsIndicatorContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Time Left: 2:00"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupRestartButton()
        setupGrid()
        setupTitle()
        setupAttemptsAndTimerLabels()
        startTimer()
    }
    
    private func setupTitle() {
        let title = UILabel()
        title.text = "Make four groups of four!"
        title.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    private func setupAttemptsAndTimerLabels() {
        // Clear any existing arranged subviews to avoid duplicates on restart.
        for subview in attemptsIndicatorContainer.arrangedSubviews {
            attemptsIndicatorContainer.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        for subview in attemptsDotsStackView.arrangedSubviews {
            attemptsDotsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        attemptsDots.removeAll()
        
        // Configure the container with the "Attempts:" title and the dots stack view.
        attemptsIndicatorContainer.addArrangedSubview(attemptsTitleLabel)
        attemptsIndicatorContainer.addArrangedSubview(attemptsDotsStackView)
        if attemptsIndicatorContainer.superview == nil {
            view.addSubview(attemptsIndicatorContainer)
        }
        
        // Create 4 dot labels.
        for _ in 0..<totalAttempts {
            let dotLabel = UILabel()
            dotLabel.text = "●"
            dotLabel.font = .systemFont(ofSize: 20)
            dotLabel.textColor = .lightGray
            attemptsDots.append(dotLabel)
            attemptsDotsStackView.addArrangedSubview(dotLabel)
        }
        
        if timerLabel.superview == nil {
            view.addSubview(timerLabel)
        }
        
        // Position the attempts container below the grid and above the restart button.
        // Here, we anchor the bottom of the attempts container to the restart button's top (with a 10-point gap)
        // and center it horizontally.
        NSLayoutConstraint.activate([
            attemptsIndicatorContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            attemptsIndicatorContainer.bottomAnchor.constraint(equalTo: restartButton.topAnchor, constant: -10),
            
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }


    
    private func setupGrid() {
        let buttonSize = view.frame.width / CGFloat(gridSize) - 15
        let verticalOffset: CGFloat = 250
        var categoryImages = generateCategoryImages()
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let button = createButton()
                button.frame = CGRect(
                    x: CGFloat(col) * (buttonSize + 10) + 12,
                    y: CGFloat(row) * (buttonSize + 10) + verticalOffset,
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
                view.addSubview(button)
            }
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
    
    private func createButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.tintColor = .clear
        button.imageView?.contentMode = .scaleAspectFit
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(tileTapped(_:)), for: .touchUpInside)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        button.addGestureRecognizer(longPress)
        return button
    }
    
    // MARK: - Tile Actions
    
    @objc private func tileTapped(_ sender: UIButton) {
        if selectedButtons.contains(sender) {
            sender.backgroundColor = .lightGray
            selectedButtons.remove(sender)
        } else {
            sender.backgroundColor = .black
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
            UIView.transition(with: button, duration: 0.5, options: .transitionFlipFromLeft, animations: {
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
            UIView.transition(with: button, duration: 0.5, options: .transitionFlipFromRight, animations: {
                button.setTitle("", for: .normal)
                if let imageName = self.buttonImages[button.tag] {
                    button.setImage(UIImage(named: imageName), for: .normal)
                }
            }, completion: nil)
        }
    }
    
    private func checkForMismatch() {
        let categoriesSet = Set(selectedButtons.compactMap { buttonCategories[$0.tag] })
        if categoriesSet.count > 1 {
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
            completedCategories.insert(firstCategory!)
            applyBorderColor(for: firstCategory!)
            disableButtons()
            selectedButtons.removeAll()
            if completedCategories.count == categories.count {
                showWinAlert()
            }
        } else {
            decrementAttempts()
            resetSelections()
        }
    }
    
    private func applyBorderColor(for category: String?) {
        guard let category = category else { return }
        let borderColor: UIColor = {
            switch category {
            case "compost": return .green
            case "recycle": return .blue
            case "hazard": return .yellow
            case "landfill": return .brown
            default: return .clear
            }
        }()
        selectedButtons.forEach { button in
            button.layer.borderWidth = 4
            button.layer.borderColor = borderColor.cgColor
        }
    }
    
    private func disableButtons() {
        selectedButtons.forEach { $0.isEnabled = false }
    }
    
    // MARK: - Attempts Handling
    
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
        let attemptsUsed = totalAttempts - attemptsLeft
        for (index, dotLabel) in attemptsDots.enumerated() {
            // Darken the dot if the attempt has been used.
            dotLabel.textColor = (index < attemptsUsed) ? .darkGray : .lightGray
        }
    }
    
    // MARK: - Restart Button
    
    private let restartButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Restart", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return button
    }()
    
    private func setupRestartButton() {
        view.addSubview(restartButton)
        restartButton.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        let buttonSize = view.frame.width / CGFloat(gridSize) - 15
        let gridHeight = CGFloat(gridSize) * (buttonSize + 10)
        let verticalOffset = 200 + gridHeight + 20
        NSLayoutConstraint.activate([
            restartButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: verticalOffset),
            restartButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restartButton.widthAnchor.constraint(equalToConstant: 120),
            restartButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func restartGame() {
        gameTimer?.invalidate()
        resetGame()
    }
    
    private func resetSelections() {
        selectedButtons.forEach {
            $0.backgroundColor = .lightGray
            $0.layer.borderWidth = 0
        }
        selectedButtons.removeAll()
    }
    
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
            title: "You Win!",
            message: "Congratulations! You matched all the groups correctly!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in self.resetGame() })
        present(alert, animated: true)
    }
    
    private func showGameOverAlert(reason: String) {
        gameTimer?.invalidate()
        let alert = UIAlertController(
            title: "Game Over",
            message: reason,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in self.resetGame() })
        present(alert, animated: true)
    }
    
    private func updateUserScore(_ score: Int) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(user.uid)
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
    
    private let leaderboardButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Leaderboard", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return button
    }()
    
    // MARK: - Timer Methods
    
    private func startTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer() {
        if remainingTime > 0 {
            remainingTime -= 1
            let minutes = remainingTime / 60
            let seconds = remainingTime % 60
            timerLabel.text = String(format: "Time Left: %01d:%02d", minutes, seconds)
        } else {
            gameTimer?.invalidate()
            showGameOverAlert(reason: "Time's up!")
        }
    }
    
    private func resetGame() {
        completedCategories.removeAll()
        selectedButtons.removeAll()
        buttonCategories.removeAll()
        buttonImages.removeAll()
        attemptsLeft = totalAttempts
        remainingTime = 120
        updateAttemptsDots()
        timerLabel.text = "Time Left: 2:00"
        view.subviews.forEach { $0.removeFromSuperview() }
        viewDidLoad()
    }
}

