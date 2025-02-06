import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class CatcherGameViewController: UIViewController {

    private var bin: UIView!
    private var scoreLabel: UILabel!
    private var gameTimer: Timer?
    private var itemTimer: Timer?

    // Array of currently falling items
    private var fallingItems: [UIImageView] = []

    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // Dimensions
    private let binWidth: CGFloat = 100
    private let binHeight: CGFloat = 50
    private let itemSize: CGFloat = 60
    private let fallSpeed: CGFloat = 2.0

    private let items = [
        "recycle": ["recycle1", "recycle2", "recycle3", "recycle4"],
        "trash":   ["trash1", "trash2", "trash3", "trash4"],
        "compost": ["compost1", "compost2", "compost3", "compost4"],
        "hazard":  ["hazard1", "hazard2", "hazard3", "hazard4"]
    ]
    
    private var hasPositionedBin = false

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupScoreLabel()
        setupBin()
        startGame()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Position the bin at the bottom center once
        if !hasPositionedBin {
            hasPositionedBin = true
            
            let safeFrame = view.safeAreaLayoutGuide.layoutFrame
            let binX = safeFrame.midX - binWidth / 2
            let binY = safeFrame.maxY - binHeight - 8
            bin.frame = CGRect(x: binX, y: binY, width: binWidth, height: binHeight)
        }
    }

    // MARK: - Setup UI
    
    private func setupScoreLabel() {
        scoreLabel = UILabel()
        scoreLabel.text = "Score: 0"
        scoreLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)

        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }

    private func setupBin() {
        bin = UIView()
        bin.backgroundColor = .blue
        bin.layer.cornerRadius = 10
        
        // We'll set its .frame in viewDidLayoutSubviews
        bin.frame = CGRect(x: 0, y: 0, width: binWidth, height: binHeight)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(moveBin(_:)))
        bin.addGestureRecognizer(panGesture)
        bin.isUserInteractionEnabled = true
        
        view.addSubview(bin)
    }

    // MARK: - Game Logic
    
    private func startGame() {
        // Timer for moving items
        gameTimer = Timer.scheduledTimer(timeInterval: 0.02,
                                         target: self,
                                         selector: #selector(updateItems),
                                         userInfo: nil,
                                         repeats: true)
        
        // Timer for spawning items
        itemTimer = Timer.scheduledTimer(timeInterval: 2.0,
                                         target: self,
                                         selector: #selector(spawnItem),
                                         userInfo: nil,
                                         repeats: true)
    }

    @objc private func moveBin(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        // Move the bin horizontally
        bin.center.x += translation.x
        
        // Keep the bin within screen bounds
        let halfWidth = bin.bounds.width / 2
        if bin.center.x < halfWidth {
            bin.center.x = halfWidth
        } else if bin.center.x > view.bounds.width - halfWidth {
            bin.center.x = view.bounds.width - halfWidth
        }

        gesture.setTranslation(.zero, in: view)
    }

    @objc private func spawnItem() {
        guard let category = items.keys.randomElement(),
              let itemName = items[category]?.randomElement() else {
            return
        }

        let item = UIImageView(image: UIImage(named: itemName))
        item.frame = CGRect(
            x: CGFloat.random(in: 0...(view.frame.width - itemSize)),
            y: -itemSize, // Start just above the top edge
            width: itemSize,
            height: itemSize
        )
        item.contentMode = .scaleAspectFit
        
        // Score “tag”: +10 for recycle, -15 otherwise
        item.tag = (category == "recycle") ? 1 : -1
        
        view.addSubview(item)
        fallingItems.append(item)  // Track it in our array
    }

    @objc private func updateItems() {
        // Move items downward and check collisions
        // Use reversed order so we can remove safely while iterating
        for (index, item) in fallingItems.enumerated().reversed() {
            item.frame.origin.y += fallSpeed

            // Check if an item intersects the bin
            if item.frame.intersects(bin.frame) {
                handleItemCatch(item: item)
                item.removeFromSuperview()
                fallingItems.remove(at: index)
            }
            // If it falls past the bottom, remove it
            else if item.frame.origin.y > view.frame.height {
                item.removeFromSuperview()
                fallingItems.remove(at: index)
            }
        }
    }

    private func handleItemCatch(item: UIView) {
        if let tag = item.tag as? Int {
            let points = (tag == 1) ? 10 : -15
            score += points
            showPointsInBin(points: points)

            if score >= 100 {
                endGame(won: true)
            }
        }
    }

    private func showPointsInBin(points: Int) {
        let pointsLabel = UILabel()
        pointsLabel.text = points > 0 ? "+\(points)" : "\(points)"
        pointsLabel.font = UIFont.boldSystemFont(ofSize: 16)
        pointsLabel.textColor = points > 0 ? .green : .red
        pointsLabel.textAlignment = .center
        
        // Start the label near the top of the bin
        pointsLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: binWidth,
            height: 30
        )
        pointsLabel.center = CGPoint(x: bin.bounds.width / 2, y: -10)
        bin.addSubview(pointsLabel)

        // Animate upwards and fade out
        UIView.animate(withDuration: 1.0, animations: {
            pointsLabel.alpha = 0
            pointsLabel.frame.origin.y -= 20
        }) { _ in
            pointsLabel.removeFromSuperview()
        }
    }

    private func endGame(won: Bool) {
        gameTimer?.invalidate()
        itemTimer?.invalidate()

        let message = won ? "You reached 100 points! Congratulations!" : "Game over. Try again!"
        let alert = UIAlertController(
            title: "Game Over",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "Restart", style: .default) { _ in
                self.restartGame()
            }
        )
        present(alert, animated: true)
    }

    private func restartGame() {
        score = 0
        // Remove all falling items from the view and clear the array
        for item in fallingItems {
            item.removeFromSuperview()
        }
        fallingItems.removeAll()
        
        hasPositionedBin = false
        startGame()
    }
}
