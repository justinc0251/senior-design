import UIKit

class ConnectionsGameViewController: UIViewController {

    let gridSize = 4
    var selectedButtons: Set<UIButton> = []

    // 4 images per category, total 16 images
    let categories: [String: [String]] = [
        "recycle": ["recycle1", "recycle2", "recycle3", "recycle4"],
        "landfill": ["landfill1", "landfill2", "landfill3", "landfill4"],
        "compost": ["compost1", "compost2", "compost3", "compost4"],
        "hazard": ["hazard1", "hazard2", "hazard3", "hazard4"]
    ]

    // Track which category each button belongs to
    var buttonCategories: [Int: String] = [:]
    // Track completed categories
    var completedCategories: Set<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupGrid()
        setupTitle()
    }

    private func setupTitle() {
        let title = UILabel()
        title.text = "Connections Game"
        title.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
        ])
    }

    private func setupGrid() {
        let buttonSize = view.frame.width / CGFloat(gridSize) - 15
        var categoryImages = generateCategoryImages()

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let button = createButton(row: row, col: col)
                button.frame = CGRect(
                    x: CGFloat(col) * (buttonSize + 10) + 13,
                    y: CGFloat(row) * (buttonSize + 10) + 200,
                    width: buttonSize,
                    height: buttonSize
                )
                let tag = row * gridSize + col
                button.tag = tag

                // Assign a random image from the shuffled categoryImages
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
        return images.shuffled() // Shuffle to randomize the order
    }

    private func createButton(row: Int, col: Int) -> UIButton {
        let button = UIButton(type: .custom) // Use .custom button type to avoid tinting
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
        checkForMismatch()
        checkForConnection()
    }

    private func checkForMismatch() {
        guard selectedButtons.count >= 2 else { return }

        let firstButton = selectedButtons.first!
        let firstCategory = buttonCategories[firstButton.tag]

        let isMismatch = selectedButtons.contains { button in
            buttonCategories[button.tag] != firstCategory
        }

        if isMismatch {
            showMismatchAlert()
            resetSelections()
        }
    }

    private func checkForConnection() {
        guard selectedButtons.count == 4 else { return }

        let firstButton = selectedButtons.first!
        let firstCategory = buttonCategories[firstButton.tag]

        let allSameCategory = selectedButtons.allSatisfy { button in
            buttonCategories[button.tag] == firstCategory
        }

        if allSameCategory {
            completedCategories.insert(firstCategory!) // Mark the category as completed
            applyBorderColor(for: firstCategory!)
            disableButtons()
            selectedButtons.removeAll()
            checkForGameCompletion() // Check if all categories are completed
        }
    }

    private func applyBorderColor(for category: String) {
        let borderColor: UIColor

        switch category {
        case "compost":
            borderColor = .green
        case "recycle":
            borderColor = .blue
        case "hazard":
            borderColor = .yellow
        case "landfill":
            borderColor = .brown
        default:
            borderColor = .clear
        }

        selectedButtons.forEach { button in
            button.layer.borderWidth = 4
            button.layer.borderColor = borderColor.cgColor
        }
    }

    private func disableButtons() {
        selectedButtons.forEach { button in
            button.isEnabled = false
        }
    }

    private func resetSelections() {
        selectedButtons.forEach { button in
            button.backgroundColor = .lightGray
            button.layer.borderWidth = 0
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

    private func checkForGameCompletion() {
        if completedCategories.count == categories.count {
            showGameOverAlert()
        }
    }

    private func showGameOverAlert() {
        let alert = UIAlertController(
            title: "You Win!",
            message: "Congratulations! You matched all the groups correctly!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.resetGame()
        }))
        present(alert, animated: true)
    }

    private func resetGame() {
        completedCategories.removeAll()
        selectedButtons.removeAll()
        buttonCategories.removeAll()
        view.subviews.forEach { $0.removeFromSuperview() }
        viewDidLoad() // Restart the game
    }
}

#Preview {
    ConnectionsGameViewController()
}
