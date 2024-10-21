import UIKit

class ConnectionsGameViewController: UIViewController {
    
    let gridSize = 4
    var selectedButtons: Set<UIButton> = []
    var attemptsLeft = 4
    var gameTimer: Timer?
    var remainingTime = 120 //2 minutes
    var correctGroups: Set<Set<Int>> = []
    
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
        setupGrid()
        setupAttemptsLabel()
        startTimer()
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
        view.addSubview(timerLabel)
        
        NSLayoutConstraint.activate([
            attemptsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            attemptsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            timerLabel.topAnchor.constraint(equalTo: attemptsLabel.bottomAnchor, constant: 10),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
        let selectedTags = Set(selectedButtons.map { $0.tag })
        
        if isValidGroup(selectedTags) {
            correctGroups.insert(selectedTags)
            resetSelection()
            
            if correctGroups.count == tileGroups.count {
                showWinAlert()
            }
        } else {
            decrementAttempts()
            resetSelection()
        }
    }
    
    private func isValidGroup(_ tags: Set<Int>) -> Bool {
        return tileGroups.contains{ Set($0) == tags }
    }

    private func showWinAlert() {
        gameTimer?.invalidate() //stop timer
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
            showGameOverAlert(reason: "You've used all your attempts!")
        }
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
            let message = attemptsLeft > 0 ? "The timer ran out!" : "You've used all your attempts!"
            showGameOverAlert(reason: message)
        }
    }
    
    private func showGameOverAlert(reason: String) {
        gameTimer?.invalidate() //stop timer
        let alert = UIAlertController(
            title: "Game Over",
            message: reason,
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
        remainingTime = 120
        timerLabel.text = "Time Left: 2:00"
        correctGroups.removeAll()
        startTimer()
    }
}

#Preview {
    ConnectionsGameViewController()
}
