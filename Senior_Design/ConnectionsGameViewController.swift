import UIKit

class ConnectionsGameViewController: UIViewController {

    let gridSize = 4
    var selectedButtons: Set<UIButton> = []
    var attemptsLeft = 4
    var gameTimer: Timer?
    var remainingTime = 120 // 2 minutes
    var completedCategories: Set<String> = []
    var buttonCategories: [Int: String] = [:]

    // 4 images per category, total 16 images
    let categories: [String: [String]] = [
        "recycle": ["recycle1", "recycle2", "recycle3", "recycle4"],
        "landfill": ["landfill1", "landfill2", "landfill3", "landfill4"],
        "compost": ["compost1", "compost2", "compost3", "compost4"],
        "hazard": ["hazard1", "hazard2", "hazard3", "hazard4"]
    ]

    private let attemptsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Attempts Left: 4"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private let timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Time Left: 2:00"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        return label
    }()

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
        title.text = "Connections Game"
        title.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }

    private func setupAttemptsAndTimerLabels() {
        view.addSubview(attemptsLabel)
        view.addSubview(timerLabel)

        NSLayoutConstraint.activate([
            attemptsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            attemptsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            timerLabel.topAnchor.constraint(equalTo: attemptsLabel.bottomAnchor, constant: 5),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupGrid() {
        let buttonSize = view.frame.width / CGFloat(gridSize) - 15
        let verticalOffset: CGFloat = 250 // Increased offset for spacing

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

                // Assign a random image and category to the button
                if let (category, image) = categoryImages.popLast() {
                    button.setImage(UIImage(named: image), for: .normal)
                    buttonCategories[tag] = category
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

        button.addTarget(self, action: #selector(tileTapped(_:)), for: .touchUpInside)
        return button
    }

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

    private func decrementAttempts() {
        attemptsLeft -= 1
        attemptsLabel.text = "Attempts Left: \(attemptsLeft)"

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

        // Calculate the total height of the grid
        let buttonSize = view.frame.width / CGFloat(gridSize) - 15
        let gridHeight = CGFloat(gridSize) * (buttonSize + 10) // Total grid height
        let verticalOffset = 200 + gridHeight + 20 // Offset below the grid

        NSLayoutConstraint.activate([
            restartButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: verticalOffset),
            restartButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restartButton.widthAnchor.constraint(equalToConstant: 120),
            restartButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    
    

    @objc private func restartGame() {
        gameTimer?.invalidate() // Stop the current timer
        resetGame() // Reset the game state
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
        attemptsLeft = 4
        remainingTime = 120
        attemptsLabel.text = "Attempts Left: 4"
        timerLabel.text = "Time Left: 2:00"
        view.subviews.forEach { $0.removeFromSuperview() }
        viewDidLoad()
    }
}

#Preview {
    ConnectionsGameViewController()
}
