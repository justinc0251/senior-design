import UIKit

class ConnectionsGameViewController: UIViewController {
    
    let gridSize = 4
    
    var selectedButtons: Set<UIButton> = []
    
    var attemptsLeft = 4
    
    let tileGroups: [[Int]] = [
        [0,1,2,3], //Landfill
        [4,5,6,7], //Recyclable
        [8,9,10,11], //Compostable
        [12,13,14,15] //Hazardous
    ]
    
    private let attemptsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Attempts Left: 4"
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupGrid()
        setupAttemptsLabel()
    }

    private func setupGrid() {
        let buttonSize = view.frame.width / CGFloat(gridSize) - 15

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let button = createButton()
                button.frame = CGRect(
                    x: CGFloat(col) * (buttonSize + 10) + 12,
                    y: CGFloat(row) * (buttonSize + 10) + 200,
                    width: buttonSize,
                    height: buttonSize
                )
                button.tag = row * gridSize + col
                view.addSubview(button)
            }
        }
    }
    
    private func setupAttemptsLabel() {
        view.addSubview(attemptsLabel)
        NSLayoutConstraint.activate([
            attemptsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            attemptsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func createButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(tileTapped(_:)), for: .touchUpInside)
        return button
    }

    @objc private func tileTapped(_ sender: UIButton) {
        if selectedButtons.contains(sender) {
            sender.backgroundColor = .lightGray
            selectedButtons.remove(sender)
        } else {
            sender.backgroundColor = .blue
            selectedButtons.insert(sender)
        }
        
        if selectedButtons.count == 4 {
            checkForConnection()
        }
        
    }

    private func checkForConnection() {
        let selectedTags = selectedButtons.map { $0.tag }
        
        if isValidGroup(selectedTags) {
            showWinAlert()
        } else {
            decrementAttempts()
            resetSelection()
        }
    }
    
    private func isValidGroup(_ tags: [Int]) -> Bool {
        for group in tileGroups {
            if Set(group).isSuperset(of: Set(tags)) {
                return true
            }
        }
        return false
    }

    private func showWinAlert() {
        let alert = UIAlertController(
            title: "You Win!",
            message: "You connected 4 tiles!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func resetSelection() {
        for button in selectedButtons {
            button.backgroundColor = .lightGray
        }
        selectedButtons.removeAll()
    }
    
    private func decrementAttempts() {
        attemptsLeft -= 1
        attemptsLabel.text = "Attempts Left: \(attemptsLeft)"
        
        if attemptsLeft == 0 {
            showGameOverAlert()
        }
    }
    
    private func showGameOverAlert() {
        let alert = UIAlertController(
            title: "Game Over",
            message: "You've used all your attempts!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) {_ in self.resetGame()
        })
        present(alert, animated: true)
    }
    
    private func resetGame() {
        resetSelection()
        attemptsLeft = 4
        attemptsLabel.text = "Attempts Left: 4"
    }
}

#Preview {
    ConnectionsGameViewController()
}
