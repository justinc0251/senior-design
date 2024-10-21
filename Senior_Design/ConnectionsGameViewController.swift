import UIKit

class ConnectionsGameViewController: UIViewController {
    
    let gridSize = 4
    
    var selectedButtons: Set<UIButton> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupGrid()
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
        checkForConnection()
    }

    private func checkForConnection() {
        if selectedButtons.count == 4 {
            showWinAlert()
        }
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
}

#Preview {
    ConnectionsGameViewController()
}
