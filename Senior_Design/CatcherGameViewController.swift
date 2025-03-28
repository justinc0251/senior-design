import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class CatcherGameViewController: UIViewController {
    
    // MARK: - Properties
    
    private var bin: UIImageView!
    private var gameTimer: Timer?
    private var itemTimer: Timer?
    private var gameTimeRemaining: Int = 60
    private var gameTimeTimer: Timer?
    private var gameContainer: UIView!
    private var fallingItems: [UIImageView] = []
    
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    private let binWidth: CGFloat = 60
    private let binHeight: CGFloat = 75
    private let itemSize: CGFloat = 60
    private let fallSpeed: CGFloat = 3.0
    
    private let items = [
        "recycle": ["recycle1", "recycle2", "recycle3", "recycle4"],
        "landfill": ["landfill1", "landfill2", "landfill3", "landfill4"],
        "compost": ["compost1", "compost2", "compost3", "compost4"],
        "hazard":  ["hazard1", "hazard2", "hazard3", "hazard4"]
    ]
    
    private var hasPositionedBin = false
    
    // MARK: - Theme Colors
    
    private enum Theme {
        static let backgroundColor = UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1.0)
        static let cardColor = UIColor.white
        static let primaryText = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1.0)
        static let secondaryText = UIColor(red: 100/255, green: 100/255, blue: 110/255, alpha: 1.0)
        static let accentColor = UIColor(red: 87/255, green: 155/255, blue: 252/255, alpha: 1.0)
        static let correctColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
        static let incorrectColor = UIColor(red: 235/255, green: 87/255, blue: 87/255, alpha: 1.0)
    }
    
    // MARK: - UI Elements
    
    private let scoreContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.cardColor
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 1
        return view
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Score: 0"
        label.font = UIFont(name: "Sen-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = Theme.primaryText
        label.textAlignment = .center
        return label
    }()
    
    private let timeContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.cardColor
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 1
        return view
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Time: 60s"
        label.font = UIFont(name: "Sen-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = Theme.primaryText
        label.textAlignment = .center
        return label
    }()
    
    private let progressContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        view.layer.cornerRadius = 6
        return view
    }()
    
    private let progressBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.accentColor
        view.layer.cornerRadius = 6
        return view
    }()
    
    private var progressBarWidthConstraint: NSLayoutConstraint!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.backgroundColor
        setupGameContainer()
        navigationItem.title = "Recycling Catcher"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = Theme.accentColor
        let helpButton = UIBarButtonItem(
            image: UIImage(systemName: "questionmark.circle"),
            style: .plain,
            target: self,
            action: #selector(showHelp)
        )
        navigationItem.rightBarButtonItem = helpButton
        setupUI()
        setupBin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showHelp()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !hasPositionedBin {
            hasPositionedBin = true
            let safeFrame = view.safeAreaLayoutGuide.layoutFrame
            let binX = safeFrame.midX - binWidth / 2
            let binY = safeFrame.maxY - binHeight - 20
            bin.frame = CGRect(x: binX, y: binY, width: binWidth, height: binHeight)
        }
    }
    
    // MARK: - Setup UI
    
    private func setupGameContainer() {
        gameContainer = UIView(frame: view.bounds)
        gameContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        gameContainer.backgroundColor = .clear
        view.addSubview(gameContainer)
    }
    
    private func setupUI() {
        view.addSubview(scoreContainer)
        scoreContainer.addSubview(scoreLabel)
        view.addSubview(timeContainer)
        timeContainer.addSubview(timeLabel)
        view.addSubview(progressContainer)
        progressContainer.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            scoreContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scoreContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scoreContainer.widthAnchor.constraint(equalToConstant: 120),
            scoreContainer.heightAnchor.constraint(equalToConstant: 50),
            
            scoreLabel.centerXAnchor.constraint(equalTo: scoreContainer.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: scoreContainer.centerYAnchor),
            
            timeContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            timeContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            timeContainer.widthAnchor.constraint(equalToConstant: 120),
            timeContainer.heightAnchor.constraint(equalToConstant: 50),
            
            timeLabel.centerXAnchor.constraint(equalTo: timeContainer.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: timeContainer.centerYAnchor),
            
            progressContainer.topAnchor.constraint(equalTo: scoreContainer.bottomAnchor, constant: 16),
            progressContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            progressContainer.heightAnchor.constraint(equalToConstant: 12),
        ])
        
        progressBarWidthConstraint = progressBar.widthAnchor.constraint(equalTo: progressContainer.widthAnchor, multiplier: 1.0)
        progressBarWidthConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: progressContainer.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor),
            progressBar.bottomAnchor.constraint(equalTo: progressContainer.bottomAnchor),
        ])
    }
    
    private func setupBin() {
        bin = UIImageView(image: UIImage(named: "recycling_bin") ?? UIImage(systemName: "trash"))
        bin.contentMode = .scaleAspectFit
        bin.backgroundColor = .clear
        bin.tintColor = Theme.accentColor
        
        if bin.image == nil {
            let binView = UIView(frame: CGRect(x: 0, y: 0, width: binWidth, height: binHeight))
            binView.backgroundColor = Theme.accentColor.withAlphaComponent(0.8)
            binView.layer.cornerRadius = 12
            binView.layer.masksToBounds = true
            
            let symbol = UIImageView(image: UIImage(systemName: "arrow.3.trianglepath"))
            symbol.tintColor = .white
            symbol.contentMode = .scaleAspectFit
            symbol.frame = CGRect(x: 25, y: 30, width: 50, height: 50)
            binView.addSubview(symbol)
            
            UIGraphicsBeginImageContextWithOptions(binView.bounds.size, false, 0)
            binView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            bin.image = image
        }
        
        bin.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        bin.layer.shadowOffset = CGSize(width: 0, height: 4)
        bin.layer.shadowRadius = 8
        bin.layer.shadowOpacity = 1
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(moveBin(_:)))
        bin.addGestureRecognizer(panGesture)
        bin.isUserInteractionEnabled = true
        
        view.addSubview(bin)
    }
    
    // MARK: - Game Logic
    
    private func startGame() {
        score = 0
        gameTimeRemaining = 60
        updateTimeLabel()
        
        UIView.animate(withDuration: 0.5) {
            self.progressBarWidthConstraint = self.progressBar.widthAnchor.constraint(equalTo: self.progressContainer.widthAnchor, multiplier: 1.0)
            self.progressBarWidthConstraint.isActive = true
            self.view.layoutIfNeeded()
        }
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.02,
                                         target: self,
                                         selector: #selector(updateItems),
                                         userInfo: nil,
                                         repeats: true)
        
        itemTimer = Timer.scheduledTimer(timeInterval: 1.5,
                                         target: self,
                                         selector: #selector(spawnItem),
                                         userInfo: nil,
                                         repeats: true)
        
        gameTimeTimer = Timer.scheduledTimer(timeInterval: 1.0, 
                                           target: self, 
                                           selector: #selector(updateGameTime), 
                                           userInfo: nil, 
                                           repeats: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.spawnItem()
        }
    }
    
    @objc private func updateGameTime() {
        gameTimeRemaining -= 1
        updateTimeLabel()
        
        let progress = CGFloat(gameTimeRemaining) / 60.0
        
        UIView.animate(withDuration: 0.3) {
            self.progressBarWidthConstraint.isActive = false
            self.progressBarWidthConstraint = self.progressBar.widthAnchor.constraint(equalTo: self.progressContainer.widthAnchor, multiplier: progress)
            self.progressBarWidthConstraint.isActive = true
            self.view.layoutIfNeeded()
        }
        
        if gameTimeRemaining <= 10 {
            UIView.animate(withDuration: 0.5, animations: {
                self.timeLabel.textColor = Theme.incorrectColor
            }) { _ in
                UIView.animate(withDuration: 0.5) {
                    self.timeLabel.textColor = Theme.primaryText
                }
            }
        }
        
        if gameTimeRemaining <= 0 {
            endGame(won: score >= 100)
        }
    }
    
    private func updateTimeLabel() {
        timeLabel.text = "Time: \(gameTimeRemaining)s"
    }
    
    @objc private func moveBin(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        bin.center.x += translation.x
        
        let halfWidth = binWidth / 2
        if bin.center.x < halfWidth {
            bin.center.x = halfWidth
        } else if bin.center.x > view.bounds.width - halfWidth {
            bin.center.x = view.bounds.width - halfWidth
        }
        
        gesture.setTranslation(.zero, in: view)
    }
    
    @objc private func spawnItem() {
        let weightedCategories = ["recycle", "recycle", "recycle", "recycle", "landfill", "compost", "hazard"]
        guard let category = weightedCategories.randomElement(),
            let itemName = items[category]?.randomElement() else {
            return
        }
        
        let item = UIImageView()
        
        if let image = UIImage(named: itemName) {
            item.image = image
        } else {
            let size = CGSize(width: itemSize, height: itemSize)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            let context = UIGraphicsGetCurrentContext()!
            
            let rect = CGRect(origin: .zero, size: size)
            context.addEllipse(in: rect)
            
            if category == "recycle" {
                Theme.accentColor.setFill()
            } else if category == "landfill" {
                UIColor(red: 163/255, green: 126/255, blue: 73/255, alpha: 1.0).setFill()
            } else if category == "compost" {
                UIColor.brown.setFill()
            } else {
                Theme.incorrectColor.setFill()
            }
            
            context.fillPath()
            
            if category == "recycle" {
                let symbolRect = CGRect(x: size.width * 0.25, y: size.width * 0.25, 
                                    width: size.width * 0.5, height: size.height * 0.5)
                UIColor.white.set()
                let path = UIBezierPath()
                path.move(to: CGPoint(x: symbolRect.midX, y: symbolRect.minY))
                path.addLine(to: CGPoint(x: symbolRect.maxX, y: symbolRect.maxY))
                path.addLine(to: CGPoint(x: symbolRect.minX, y: symbolRect.maxY))
                path.close()
                path.stroke()
            }
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            item.image = image
        }
        
        item.contentMode = .scaleAspectFit
        let startY = view.safeAreaInsets.top + 150
        
        item.frame = CGRect(
            x: CGFloat.random(in: 20...(view.frame.width - itemSize - 20)),
            y: startY,
            width: itemSize,
            height: itemSize
        )
        
        item.tag = (category == "recycle") ? 10 : -15
        
        gameContainer.addSubview(item)
        fallingItems.append(item)
    }
    
    @objc private func updateItems() {
        for (index, item) in fallingItems.enumerated().reversed() {
            item.frame.origin.y += fallSpeed
            
            if item.frame.intersects(bin.frame) {
                handleItemCatch(item: item)
                item.removeFromSuperview()
                fallingItems.remove(at: index)
            }
            else if item.frame.origin.y > view.frame.height {
                item.removeFromSuperview()
                fallingItems.remove(at: index)
            }
        }
    }
    
    private func handleItemCatch(item: UIImageView) {
        let points = item.tag
        score += points
        
        UIView.animate(withDuration: 0.3, animations: {
            self.scoreLabel.textColor = points > 0 ? Theme.correctColor : Theme.incorrectColor
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.scoreLabel.textColor = Theme.primaryText
            }
        }
        
        showPointsInBin(points: points)
        
        let generator = UIImpactFeedbackGenerator(style: points > 0 ? .medium : .heavy)
        generator.impactOccurred()
        
        if score >= 100 {
            endGame(won: true)
        }
    }
    
    private func showPointsInBin(points: Int) {
        let pointsLabel = UILabel()
        pointsLabel.text = points > 0 ? "+\(points)" : "\(points)"
        pointsLabel.font = UIFont.boldSystemFont(ofSize: 20)
        pointsLabel.textColor = points > 0 ? Theme.correctColor : Theme.incorrectColor
        pointsLabel.textAlignment = .center
        
        pointsLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: binWidth,
            height: 30
        )
        pointsLabel.center = CGPoint(x: bin.bounds.width / 2, y: bin.bounds.height / 2)
        bin.addSubview(pointsLabel)
        
        UIView.animate(withDuration: 1.0, animations: {
            pointsLabel.alpha = 0
            pointsLabel.frame.origin.y -= 40
        }) { _ in
            pointsLabel.removeFromSuperview()
        }
    }
    
    private func endGame(won: Bool) {
        gameTimer?.invalidate()
        itemTimer?.invalidate()
        gameTimeTimer?.invalidate()
        
        if won {
            UserDefaults.standard.set(true, forKey: "game_1_completed")
            updateUserScore(score)
        }
        
        let resultContainerView = UIView()
        resultContainerView.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.backgroundColor = Theme.cardColor
        resultContainerView.layer.cornerRadius = 20
        resultContainerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        resultContainerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        resultContainerView.layer.shadowRadius = 20
        resultContainerView.layer.shadowOpacity = 1
        resultContainerView.alpha = 0
        view.addSubview(resultContainerView)
        
        NSLayoutConstraint.activate([
            resultContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            resultContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            resultContainerView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        let resultIcon = UIImageView()
        resultIcon.translatesAutoresizingMaskIntoConstraints = false
        resultIcon.contentMode = .scaleAspectFit
        resultIcon.tintColor = won ? Theme.correctColor : Theme.accentColor
        resultIcon.image = UIImage(systemName: won ? "checkmark.circle.fill" : "hourglass")
        resultContainerView.addSubview(resultIcon)
        
        let resultTitle = UILabel()
        resultTitle.translatesAutoresizingMaskIntoConstraints = false
        resultTitle.text = won ? "You Win!" : "Game Over"
        resultTitle.font = UIFont(name: "Sen-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        resultTitle.textColor = Theme.primaryText
        resultTitle.textAlignment = .center
        resultContainerView.addSubview(resultTitle)
        
        let resultMessage = UILabel()
        resultMessage.translatesAutoresizingMaskIntoConstraints = false
        resultMessage.text = won ? "You reached 100 points! Great recycling!" : "You scored \(score) points. Try again!"
        resultMessage.font = UIFont(name: "Sen-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)
        resultMessage.textColor = Theme.secondaryText
        resultMessage.textAlignment = .center
        resultMessage.numberOfLines = 0
        resultContainerView.addSubview(resultMessage)
        
        let restartButton = UIButton(type: .system)
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        restartButton.setTitle("Play Again", for: .normal)
        restartButton.titleLabel?.font = UIFont(name: "Sen-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        restartButton.setTitleColor(.white, for: .normal)
        restartButton.backgroundColor = Theme.accentColor
        restartButton.layer.cornerRadius = 25
        restartButton.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        resultContainerView.addSubview(restartButton)
        
        NSLayoutConstraint.activate([
            resultIcon.topAnchor.constraint(equalTo: resultContainerView.topAnchor, constant: 30),
            resultIcon.centerXAnchor.constraint(equalTo: resultContainerView.centerXAnchor),
            resultIcon.widthAnchor.constraint(equalToConstant: 70),
            resultIcon.heightAnchor.constraint(equalToConstant: 70),
            
            resultTitle.topAnchor.constraint(equalTo: resultIcon.bottomAnchor, constant: 16),
            resultTitle.leadingAnchor.constraint(equalTo: resultContainerView.leadingAnchor, constant: 20),
            resultTitle.trailingAnchor.constraint(equalTo: resultContainerView.trailingAnchor, constant: -20),
            
            resultMessage.topAnchor.constraint(equalTo: resultTitle.bottomAnchor, constant: 12),
            resultMessage.leadingAnchor.constraint(equalTo: resultContainerView.leadingAnchor, constant: 20),
            resultMessage.trailingAnchor.constraint(equalTo: resultContainerView.trailingAnchor, constant: -20),
            
            restartButton.bottomAnchor.constraint(equalTo: resultContainerView.bottomAnchor, constant: -30),
            restartButton.centerXAnchor.constraint(equalTo: resultContainerView.centerXAnchor),
            restartButton.widthAnchor.constraint(equalToConstant: 200),
            restartButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            resultContainerView.alpha = 1
        })
    }
    
    @objc private func restartGame() {
        for item in fallingItems {
            item.removeFromSuperview()
        }
        fallingItems.removeAll()
        
        for subview in view.subviews {
            if subview != scoreContainer && subview != timeContainer && 
               subview != progressContainer && subview != bin &&
               subview != gameContainer {
                UIView.animate(withDuration: 0.3, animations: {
                    subview.alpha = 0
                }) { _ in
                    subview.removeFromSuperview()
                }
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.progressBarWidthConstraint.isActive = false
            self.progressBarWidthConstraint = self.progressBar.widthAnchor.constraint(equalTo: self.progressContainer.widthAnchor, multiplier: 1.0)
            self.progressBarWidthConstraint.isActive = true
            self.view.layoutIfNeeded()
        }
        
        score = 0
        gameTimeRemaining = 60
        updateTimeLabel()
        startGame()
    }
    
    @objc private func showHelp() {
        gameTimer?.invalidate()
        itemTimer?.invalidate()
        gameTimeTimer?.invalidate()
        
        let alertController = UIAlertController(
            title: "How to Play",
            message: "Catch the recycling items with your bin to score points!\n\n• Drag the bin left and right to catch items\n• Recycling items: +10 points\n• Other waste items: -15 points\n• Reach 100 points to win\n• You have 60 seconds",
            preferredStyle: .alert
        )
        
        let startAction = UIAlertAction(title: "Start Game", style: .default) { _ in
            self.startGame()
        }
        
        alertController.addAction(startAction)
        present(alertController, animated: true)
    }
    
    // MARK: - Firebase
    
    private func updateUserScore(_ score: Int) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(user.uid)
        
        userDoc.updateData([
            "score": FieldValue.increment(Int64(score))
        ]) { error in
            if let error = error {
                print("Error updating score: \(error.localizedDescription)")
            }
        }
    }
}