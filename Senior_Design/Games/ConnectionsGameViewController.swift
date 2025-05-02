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
    
    // Tutorial properties
    private var isTutorialActive = false
    private var tutorialStep = 0
    private var tutorialTargetButton: UIButton?
    private var tutorialOverlayView: UIView?
    private var tutorialHandView: UIImageView?
    private var tutorialMessageView: UIView?
    
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
        
        navigationController?.navigationBar.tintColor = Theme.accentColor
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        
        headerView.backgroundColor = .clear
        headerView.layer.shadowOpacity = 0
        attemptsContainerView.backgroundColor = .clear
        attemptsContainerView.layer.shadowOpacity = 0
        
        // Check if user has played this game before
        let hasPlayedBefore = UserDefaults.standard.bool(forKey: "connections_tutorial_shown")
        
        if !hasPlayedBefore {
            // First time playing - show welcome/tutorial modal
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showWelcomeModal()
            }
        } else {
            // Returning player - start game directly
            startTimer()
        }
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
        
        let statusBarHeight: CGFloat = {
            if #available(iOS 13.0, *) {
                return view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            } else {
                return UIApplication.shared.statusBarFrame.height
            }
        }()
        
        let topMargin = statusBarHeight + 100
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: topMargin),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
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
        
        let wasSelected = selectedButtons.contains(sender)
        
        // Prevent deselection of tutorial target buttons during step 2
        if wasSelected && isTutorialActive && tutorialStep == 2 && sender.accessibilityIdentifier == "tutorialTargetButton" {
            // Don't allow deselection of correctly selected tutorial buttons
            return
        }
        
        if wasSelected {
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
        
        // Send notification after updating the selectedButtons collection
        if isTutorialActive && tutorialStep == 2 {
            NotificationCenter.default.post(
                name: NSNotification.Name("TutorialButtonTapped"),
                object: sender
            )
        }
        
        if selectedButtons.count == 4 {
            checkForConnection()
        } else if selectedButtons.count > 1 {
            checkForMismatch()
        }
    }
    
    private func generateCategoryImages() -> [(String, String)] {
        var images: [(String, String)] = []
        
        for (category, imageNames) in WasteData.shared.categories {
            let selectedImages = Array(imageNames.shuffled().prefix(4))
            
            for image in selectedImages {
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
            showMismatchIndicators()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if !self.isTutorialActive {
                    self.decrementAttempts()
                }
                self.resetSelections()
            }
        }
    }
    
    private func showMismatchIndicators() {
        for subview in gridContainerView.subviews {
            if let button = subview as? UIButton {
                button.isUserInteractionEnabled = false
            }
        }
        
        for button in selectedButtons {
            let xMarkView = UIImageView(image: UIImage(systemName: "xmark"))
            xMarkView.tintColor = UIColor.red
            xMarkView.contentMode = .scaleAspectFit
            xMarkView.translatesAutoresizingMaskIntoConstraints = false
            xMarkView.alpha = 0
            xMarkView.tag = 888
            
            button.backgroundColor = UIColor.red.withAlphaComponent(0.2)
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.red.cgColor
            
            button.addSubview(xMarkView)
            
            NSLayoutConstraint.activate([
                xMarkView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                xMarkView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                xMarkView.widthAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.5),
                xMarkView.heightAnchor.constraint(equalTo: button.heightAnchor, multiplier: 0.5)
            ])
            
            UIView.animate(withDuration: 0.2) {
                xMarkView.alpha = 1
                button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
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
            
            if completedCategories.count == WasteData.shared.categories.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showWinAlert()
                }
            }
        } else {
            showMismatchIndicators()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.decrementAttempts()
                self.resetSelections()
            }
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
                
                button.subviews.forEach { subview in
                    if subview.tag == 888 {
                        subview.removeFromSuperview()
                    }
                }
            }
        }
        selectedButtons.removeAll()
        
        for subview in gridContainerView.subviews {
            if let button = subview as? UIButton, button.isEnabled {
                button.isUserInteractionEnabled = true
            }
        }
    }
    
    // MARK: - Timer Methods
    
    private func startTimer() {
        // Always invalidate any existing timer first
        gameTimer?.invalidate()
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
    
    private func showWinAlert() {
        gameTimer?.invalidate()

        GameHistoryManager.shared.saveGameHistory(gameName: "Connections", score: 10)
        
        // Add a blocking overlay to prevent interaction with background elements
        let blockingOverlay = UIView(frame: view.bounds)
        blockingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.2) // Semi-transparent overlay
        blockingOverlay.isUserInteractionEnabled = true
        blockingOverlay.tag = 998
        view.addSubview(blockingOverlay)
        
        let resultContainerView = UIView()
        resultContainerView.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.backgroundColor = Theme.cardColor
        resultContainerView.layer.cornerRadius = 20
        resultContainerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        resultContainerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        resultContainerView.layer.shadowRadius = 20
        resultContainerView.layer.shadowOpacity = 1
        resultContainerView.alpha = 0
        resultContainerView.tag = 999  // Add tag to identify this view for removal
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
        resultIcon.tintColor = Theme.accentColor
        resultIcon.image = UIImage(systemName: "checkmark.circle.fill")
        resultContainerView.addSubview(resultIcon)
        
        let resultTitle = UILabel()
        resultTitle.translatesAutoresizingMaskIntoConstraints = false
        resultTitle.text = "You Win! 🎉"
        resultTitle.font = UIFont(name: "Sen-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        resultTitle.textColor = Theme.primaryText
        resultTitle.textAlignment = .center
        resultContainerView.addSubview(resultTitle)
        
        let resultMessage = UILabel()
        resultMessage.translatesAutoresizingMaskIntoConstraints = false
        resultMessage.text = "Congratulations! You matched all the groups correctly!"
        resultMessage.font = UIFont(name: "Sen-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)
        resultMessage.textColor = Theme.secondaryText
        resultMessage.textAlignment = .center
        resultMessage.numberOfLines = 0
        resultContainerView.addSubview(resultMessage)
        
        let playAgainButton = UIButton(type: .system)
        playAgainButton.translatesAutoresizingMaskIntoConstraints = false
        playAgainButton.setTitle("Play Again", for: .normal)
        playAgainButton.titleLabel?.font = UIFont(name: "Sen-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        playAgainButton.setTitleColor(.white, for: .normal)
        playAgainButton.backgroundColor = Theme.accentColor
        playAgainButton.layer.cornerRadius = 25
        playAgainButton.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        resultContainerView.addSubview(playAgainButton)
        
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
            
            playAgainButton.bottomAnchor.constraint(equalTo: resultContainerView.bottomAnchor, constant: -30),
            playAgainButton.centerXAnchor.constraint(equalTo: resultContainerView.centerXAnchor),
            playAgainButton.widthAnchor.constraint(equalToConstant: 200),
            playAgainButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            resultContainerView.alpha = 1
        })
    }

    private func cleanupTutorialState() {
        // Remove all tutorial-related notification observers
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("TutorialLongPressCompleted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("TutorialButtonTapped"), object: nil)
        
        // Reset tutorial state variables
        isTutorialActive = false
        tutorialStep = 0
        tutorialTargetButton = nil
        
        // Remove any UI elements from previous tutorial
        tutorialOverlayView?.removeFromSuperview()
        tutorialOverlayView = nil
        tutorialHandView?.removeFromSuperview()
        tutorialHandView = nil
        tutorialMessageView?.removeFromSuperview()
        tutorialMessageView = nil
        
        // Reset any buttons with tutorial identifiers
        for subview in gridContainerView.subviews {
            if let button = subview as? UIButton {
                button.accessibilityIdentifier = nil
                button.layer.borderWidth = 0
                button.layer.borderColor = nil
                button.isUserInteractionEnabled = true
                button.layer.masksToBounds = false
            }
        }
        
        // Remove any pulse effects
        view.subviews.forEach { subview in
            if subview.tag == 1234 {
                subview.removeFromSuperview()
            }
        }
    }
    
    private func showGameOverAlert(reason: String) {
        gameTimer?.invalidate()
        
        view.subviews.forEach { view in
            if view.tag == 999 {
                view.removeFromSuperview()
            }
        }
        
        selectedButtons.forEach { button in
            button.backgroundColor = Theme.cardColor
            button.transform = .identity
            button.layer.borderWidth = 0
            
            button.subviews.forEach { subview in
                if subview.tag == 888 {
                    subview.removeFromSuperview()
                }
            }
        }
        selectedButtons.removeAll()
        
        // Add a blocking overlay to prevent interaction with background elements
        let blockingOverlay = UIView(frame: view.bounds)
        blockingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        blockingOverlay.isUserInteractionEnabled = true
        blockingOverlay.tag = 998
        view.addSubview(blockingOverlay)
        
        let resultContainerView = UIView()
        resultContainerView.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.backgroundColor = Theme.cardColor
        resultContainerView.layer.cornerRadius = 20
        resultContainerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        resultContainerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        resultContainerView.layer.shadowRadius = 20
        resultContainerView.layer.shadowOpacity = 1
        resultContainerView.alpha = 0
        resultContainerView.tag = 999
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
        resultIcon.tintColor = UIColor(red: 235/255, green: 87/255, blue: 87/255, alpha: 1.0)
        resultIcon.image = UIImage(systemName: "hourglass")
        resultContainerView.addSubview(resultIcon)
        
        let resultTitle = UILabel()
        resultTitle.translatesAutoresizingMaskIntoConstraints = false
        resultTitle.text = "Game Over"
        resultTitle.font = UIFont(name: "Sen-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        resultTitle.textColor = Theme.primaryText
        resultTitle.textAlignment = .center
        resultContainerView.addSubview(resultTitle)
        
        let resultMessage = UILabel()
        resultMessage.translatesAutoresizingMaskIntoConstraints = false
        resultMessage.text = reason
        resultMessage.font = UIFont(name: "Sen-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)
        resultMessage.textColor = Theme.secondaryText
        resultMessage.textAlignment = .center
        resultMessage.numberOfLines = 0
        resultContainerView.addSubview(resultMessage)
        
        let showAnswersButton = UIButton(type: .system)
        showAnswersButton.translatesAutoresizingMaskIntoConstraints = false
        showAnswersButton.setTitle("Show Answers", for: .normal)
        showAnswersButton.titleLabel?.font = UIFont(name: "Sen-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        showAnswersButton.setTitleColor(.white, for: .normal)
        showAnswersButton.backgroundColor = Theme.accentColor
        showAnswersButton.layer.cornerRadius = 25
        showAnswersButton.tag = 1001
        showAnswersButton.addTarget(self, action: #selector(showAnswersTapped), for: .touchUpInside)
        resultContainerView.addSubview(showAnswersButton)
        
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
            
            showAnswersButton.bottomAnchor.constraint(equalTo: resultContainerView.bottomAnchor, constant: -30),
            showAnswersButton.centerXAnchor.constraint(equalTo: resultContainerView.centerXAnchor),
            showAnswersButton.widthAnchor.constraint(equalToConstant: 200),
            showAnswersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            resultContainerView.alpha = 1
        })
    }
    
    @objc private func tryAgainTapped() {
        view.subviews.forEach { view in
            if view.tag == 999 {
                UIView.animate(withDuration: 0.3, animations: {
                    view.alpha = 0
                }) { _ in
                    view.removeFromSuperview()
                }
            }
        }
        
        restartGame()
    }

    private func revealCorrectAnswers() {
        var buttonsByCategory: [String: [UIButton]] = [:]
        
        for subview in gridContainerView.subviews {
            if let button = subview as? UIButton, 
            let category = buttonCategories[button.tag],
            !completedCategories.contains(category) {
                if buttonsByCategory[category] == nil {
                    buttonsByCategory[category] = []
                }
                buttonsByCategory[category]?.append(button)
            }
        }
        
        for (category, buttons) in buttonsByCategory {
            let borderColor = Theme.categoryColors[category] ?? Theme.accentColor
            let delayInterval = 0.3
            
            for (index, button) in buttons.enumerated() {
                UIView.animate(withDuration: 0.5, 
                            delay: Double(index) * delayInterval, 
                            options: [], 
                            animations: {
                    button.layer.borderWidth = 4
                    button.layer.borderColor = borderColor.cgColor
                    button.backgroundColor = borderColor.withAlphaComponent(0.3)
                    button.alpha = 0.8
                })
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func helpButtonTapped() {
        gameTimer?.invalidate()
        
        // Add a blocking overlay to prevent interaction with background elements
        let blockingOverlay = UIView(frame: view.bounds)
        blockingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.2) // Semi-transparent overlay
        blockingOverlay.isUserInteractionEnabled = true
        blockingOverlay.tag = 998
        view.addSubview(blockingOverlay)
        
        let helpContainerView = UIView()
        helpContainerView.translatesAutoresizingMaskIntoConstraints = false
        helpContainerView.backgroundColor = Theme.cardColor
        helpContainerView.layer.cornerRadius = 20
        helpContainerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        helpContainerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        helpContainerView.layer.shadowRadius = 20
        helpContainerView.layer.shadowOpacity = 1
        helpContainerView.alpha = 0
        helpContainerView.tag = 999
        view.addSubview(helpContainerView)
        
        NSLayoutConstraint.activate([
            helpContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            helpContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            helpContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            helpContainerView.heightAnchor.constraint(equalToConstant: 640) // Increased height to accommodate the new button
        ])
        
        let helpIcon = UIImageView()
        helpIcon.translatesAutoresizingMaskIntoConstraints = false
        helpIcon.contentMode = .scaleAspectFit
        helpIcon.tintColor = Theme.accentColor
        helpIcon.image = UIImage(systemName: "questionmark.circle.fill")
        helpContainerView.addSubview(helpIcon)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "How to Play"
        titleLabel.font = UIFont(name: "Sen-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = Theme.primaryText
        titleLabel.textAlignment = .center
        helpContainerView.addSubview(titleLabel)
        
        let instructionsLabel = UILabel()
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.text = "Find groups of 4 items that belong to the same waste category.\n\n• Long press on a tile to see what the object is\n• Select 4 tiles of the same category to form a group\n• You have 4 attempts to find all groups\n\nCategories:\n• Landfill = Brown\n• Recycling = Blue\n• Compost = Green\n• Hazardous = Yellow"
        instructionsLabel.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        instructionsLabel.textColor = Theme.secondaryText
        instructionsLabel.textAlignment = .left
        instructionsLabel.numberOfLines = 0
        helpContainerView.addSubview(instructionsLabel)
        
        // Play Tutorial button
        let playTutorialButton = UIButton(type: .system)
        playTutorialButton.translatesAutoresizingMaskIntoConstraints = false
        playTutorialButton.setTitle("Play Tutorial Again", for: .normal)
        playTutorialButton.titleLabel?.font = UIFont(name: "Sen-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        playTutorialButton.setTitleColor(.white, for: .normal)
        playTutorialButton.backgroundColor = Theme.accentColor
        playTutorialButton.layer.cornerRadius = 25
        playTutorialButton.addTarget(self, action: #selector(playTutorialFromHelp), for: .touchUpInside)
        helpContainerView.addSubview(playTutorialButton)
        
        // Got it button
        let gotItButton = UIButton(type: .system)
        gotItButton.translatesAutoresizingMaskIntoConstraints = false
        gotItButton.setTitle("Got it", for: .normal)
        gotItButton.titleLabel?.font = UIFont(name: "Sen-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        gotItButton.setTitleColor(Theme.secondaryText, for: .normal)
        gotItButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        gotItButton.layer.cornerRadius = 25
        gotItButton.addTarget(self, action: #selector(dismissHelpModal), for: .touchUpInside)
        helpContainerView.addSubview(gotItButton)
        
        NSLayoutConstraint.activate([
            helpIcon.topAnchor.constraint(equalTo: helpContainerView.topAnchor, constant: 30),
            helpIcon.centerXAnchor.constraint(equalTo: helpContainerView.centerXAnchor),
            helpIcon.widthAnchor.constraint(equalToConstant: 60),
            helpIcon.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: helpIcon.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: helpContainerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: helpContainerView.trailingAnchor, constant: -20),
            
            instructionsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            instructionsLabel.leadingAnchor.constraint(equalTo: helpContainerView.leadingAnchor, constant: 24),
            instructionsLabel.trailingAnchor.constraint(equalTo: helpContainerView.trailingAnchor, constant: -24),
            instructionsLabel.bottomAnchor.constraint(lessThanOrEqualTo: playTutorialButton.topAnchor, constant: -30),
            
            // Play Tutorial button - positioned above Got it button
            playTutorialButton.bottomAnchor.constraint(equalTo: gotItButton.topAnchor, constant: -15),
            playTutorialButton.centerXAnchor.constraint(equalTo: helpContainerView.centerXAnchor),
            playTutorialButton.widthAnchor.constraint(equalToConstant: 200),
            playTutorialButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Got it button at the bottom
            gotItButton.bottomAnchor.constraint(equalTo: helpContainerView.bottomAnchor, constant: -40),
            gotItButton.centerXAnchor.constraint(equalTo: helpContainerView.centerXAnchor),
            gotItButton.widthAnchor.constraint(equalToConstant: 200),
            gotItButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Also add a dismissal handler for the blocking overlay
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissHelpModal))
        blockingOverlay.addGestureRecognizer(tapGesture)
        
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            helpContainerView.alpha = 1
        })
    }

    // Add this new method to handle the play tutorial button action
    @objc private func playTutorialFromHelp() {
        // Remove the help modal and blocking overlay first
        for subview in view.subviews where subview.tag == 999 || subview.tag == 998 {
            UIView.animate(withDuration: 0.3, animations: {
                subview.alpha = 0
            }) { [weak self] _ in
                guard let self = self else { return }
                subview.removeFromSuperview()
                
                // When last overlay is removed, reset the game and then start tutorial
                if subview.tag == 999 {
                    // Clean up any existing tutorial state first
                    self.cleanupTutorialState()
                    
                    // Reset game state (reuse code from restartGame but without starting timer)
                    self.gameTimer?.invalidate()
                    self.gameTimer = nil
                    
                    self.completedCategories.removeAll()
                    self.selectedButtons.removeAll()
                    self.buttonCategories.removeAll()
                    self.buttonImages.removeAll()
                    self.attemptsLeft = self.totalAttempts
                    self.remainingTime = 120
                    
                    self.timerLabel.textColor = Theme.primaryText
                    self.timerLabel.text = "2:00"
                    
                    // Clear grid elements
                    for subview in self.gridContainerView.subviews {
                        UIView.animate(withDuration: 0.2, animations: {
                            subview.alpha = 0
                        }) { _ in
                            subview.removeFromSuperview()
                        }
                    }
                    
                    // Give time for animations to complete before rebuilding grid
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.setupGrid()
                        self.updateAttemptsDots()
                        
                        // Now start tutorial with fresh game state
                        self.startTutorial()
                    }
                }
            }
        }
    }

    @objc private func dismissHelpModal() {
        // We should always restart the timer when dismissing the help modal
        // since we know it was invalidated when opening the help modal
        
        for subview in view.subviews where subview.tag == 999 || subview.tag == 998 {
            UIView.animate(withDuration: 0.3, animations: {
                subview.alpha = 0
            }) { [weak self] finished in
                guard let self = self else { return }
                subview.removeFromSuperview()
                
                // Only start the timer once, when the modal itself is removed
                if subview.tag == 999 {
                    self.gameTimer?.invalidate() // Cancel any existing timer just to be safe
                    self.startTimer()
                }
            }
        }
    }

    @objc private func showAnswersTapped(_ sender: UIButton) {
        view.subviews.forEach { view in
            if view.tag == 999 || view.tag == 998 {  // Remove both modal and blocking overlay
                UIView.animate(withDuration: 0.3, animations: {
                    view.alpha = 0
                }) { _ in
                    view.removeFromSuperview()
                    if view.tag == 999 {  // Only call revealCorrectAnswers once
                        self.revealCorrectAnswers()
                    }
                }
            }
        }
    }
    
    @objc private func restartGame() {
        // Invalidate the existing timer first
        gameTimer?.invalidate()
        gameTimer = nil
        
        // First remove any modal views AND blocking overlays
        view.subviews.forEach { view in
            if view.tag == 999 || view.tag == 998 {
                UIView.animate(withDuration: 0.3, animations: {
                    view.alpha = 0
                }) { _ in
                    view.removeFromSuperview()
                }
            }
        }
        
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

// MARK: - Tutorial
extension ConnectionsGameViewController {
    private func startTutorial() {
        isTutorialActive = true
        gameTimer?.invalidate()
        
        disableAllButtonsExcept(nil)
        
        showTileTutorial()
    }
    
    private func showTileTutorial() {
        tutorialStep = 1
        
        if let button = gridContainerView.subviews.compactMap({ $0 as? UIButton }).randomElement() {
            tutorialTargetButton = button
            
            createTutorialOverlay()
            
            let message = "Long press on a tile to see what the object is"
            createTutorialMessage(message)
            
            demonstrateLongPress(on: button)
            
            disableAllButtonsExcept(button)
            
            addTutorialGestureObserver()
        }
    }
    
    // MARK: - Tutorial overlay

    private func createTutorialOverlay() {
        tutorialOverlayView?.removeFromSuperview()
        
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = .clear
        view.addSubview(overlay)
        tutorialOverlayView = overlay
        
        var targetButtons: [UIButton] = []
        if tutorialStep == 1, let btn = tutorialTargetButton {
            targetButtons = [btn]
        } else if tutorialStep == 2 {
            targetButtons = gridContainerView.subviews.compactMap {
                ($0 as? UIButton)?.accessibilityIdentifier == "tutorialTargetButton" ? $0 as? UIButton : nil
            }
        }
        
        for case let button as UIButton in gridContainerView.subviews {
            if targetButtons.contains(button) {
                button.superview?.bringSubviewToFront(button)
                button.isUserInteractionEnabled = true
                button.layer.borderWidth = 3
                button.layer.borderColor = Theme.accentColor.cgColor
                button.layer.masksToBounds = true
            } else if tutorialStep == 1 {
                // Only dim non-target buttons in step 1
                let dimView = UIView(frame: button.convert(button.bounds, to: view))
                dimView.backgroundColor = UIColor.black.withAlphaComponent(0.65)
                dimView.layer.cornerRadius = button.layer.cornerRadius
                overlay.addSubview(dimView)
            } else {
                // Keep all buttons interactive in step 2
                button.isUserInteractionEnabled = true
            }
        }
        
        overlay.isUserInteractionEnabled = false
    }

    
    private func createTutorialMessage(_ text: String) {
        tutorialMessageView?.removeFromSuperview()
        
        let messageView = UIView()
        messageView.backgroundColor = Theme.cardColor
        messageView.layer.cornerRadius = 12
        messageView.layer.shadowColor = UIColor.black.cgColor
        messageView.layer.shadowOpacity = 0.3
        messageView.layer.shadowOffset = CGSize(width: 0, height: 3)
        messageView.layer.shadowRadius = 5
        messageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageView)
        tutorialMessageView = messageView
        
        let messageLabel = UILabel()
        messageLabel.text = text
        messageLabel.font = UIFont(name: "Sen-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        messageLabel.textColor = Theme.primaryText
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -140),  // Changed from -100 to -140
            messageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            messageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            messageLabel.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -16),
            messageLabel.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -20)
        ])
    }
    
    private func demonstrateLongPress(on button: UIButton) {
        tutorialHandView?.removeFromSuperview()
        
        let handImage = UIImage(systemName: "hand.point.up.fill")
        let handView = UIImageView(image: handImage)
        handView.tintColor = .white
        handView.contentMode = .scaleAspectFit
        handView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(handView)
        tutorialHandView = handView
        
        let buttonFrame = button.convert(button.bounds, to: view)
        
        NSLayoutConstraint.activate([
            handView.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: buttonFrame.midX),
            handView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: buttonFrame.maxY + 40),
            handView.widthAnchor.constraint(equalToConstant: 40),
            handView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        UIView.animate(withDuration: 0.5, animations: {
            handView.transform = CGAffineTransform(translationX: 0, y: -20)
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                handView.transform = CGAffineTransform(translationX: 0, y: 0)
            }) { _ in
                self.animatePulseLongPress(around: button)
            }
        }
    }
    
    private func animatePulseLongPress(around button: UIButton) {
        let buttonFrame = button.convert(button.bounds, to: view)
        
        let pulseView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        pulseView.backgroundColor = Theme.accentColor
        pulseView.alpha = 0.3
        pulseView.layer.cornerRadius = 25
        pulseView.center = CGPoint(x: buttonFrame.midX, y: buttonFrame.midY)
        pulseView.isUserInteractionEnabled = false
        pulseView.tag = 1234 // Add tag so we can find and remove this view later
        view.addSubview(pulseView)
        
        button.superview?.bringSubviewToFront(button)
        
        UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseOut, .repeat], animations: {
            pulseView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            pulseView.alpha = 0
        })
    }
    
    private func simulateLongPress(on button: UIButton) {
        UIView.transition(with: button, duration: 0.3, options: .transitionFlipFromLeft, animations: {
            button.setImage(nil, for: .normal)
            if let imageName = self.buttonImages[button.tag] {
                let originalDescription = WasteData.shared.getItemTitle(for: imageName)
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
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                UIView.transition(with: button, duration: 0.3, options: .transitionFlipFromRight, animations: {
                    button.setTitle("", for: .normal)
                    if let imageName = self.buttonImages[button.tag] {
                        button.setImage(UIImage(named: imageName), for: .normal)
                    }
                }) { _ in
                    // Do not prompt the user again, just continue showing the pulsing animation
                }
            }
        }
    }
    
    private func updateTutorialMessage(_ text: String) {
        tutorialMessageView?.removeFromSuperview()
        createTutorialMessage(text)
    }
    
    private func disableAllButtonsExcept(_ exception: UIButton?) {
        for subview in gridContainerView.subviews {
            if let button = subview as? UIButton {
                if button == exception {
                    button.isUserInteractionEnabled = true
                } else {
                    button.isUserInteractionEnabled = false
                }
            }
        }
    }
    
    private func addTutorialGestureObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTutorialGestureCompleted),
            name: NSNotification.Name("TutorialLongPressCompleted"),
            object: nil
        )
    }
    
    @objc private func handleTutorialGestureCompleted() {
        // Remove pulse effects immediately after gesture is completed
        view.subviews.forEach { subview in
            if subview.tag == 1234 {
                subview.removeFromSuperview()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.completeTutorial()
        }
    }
    
    private func completeTutorial() {
        tutorialOverlayView?.removeFromSuperview()
        tutorialHandView?.removeFromSuperview()
        tutorialMessageView?.removeFromSuperview()
        
        // Store the tutorial target buttons and their category before resetting appearances
        let targetButtons = gridContainerView.subviews.compactMap { view -> UIButton? in
            if let button = view as? UIButton, button.accessibilityIdentifier == "tutorialTargetButton" {
                return button
            }
            return nil
        }
        
        // Get the category for these buttons (they should all be the same)
        var targetCategory: String?
        if let firstButton = targetButtons.first, let tag = firstButton.tag as Int?, let category = buttonCategories[tag] {
            targetCategory = category
        }
        
        // Reset button appearances EXCEPT for the target buttons from step 2
        for subview in gridContainerView.subviews {
            if let button = subview as? UIButton {
                // Don't reset border for tutorial target buttons in step 2
                if tutorialStep == 2 && button.accessibilityIdentifier == "tutorialTargetButton" {
                    // Keep the border, just remove the identifier and ensure interaction
                    button.accessibilityIdentifier = nil
                    button.isUserInteractionEnabled = true
                    button.layer.masksToBounds = false
                } else {
                    // Reset completely for non-target buttons
                    button.layer.borderWidth = 0
                    button.layer.borderColor = nil
                    button.accessibilityIdentifier = nil
                    button.layer.masksToBounds = false
                    button.isUserInteractionEnabled = true
                }
            }
        }
        
        // Remove any pulse effects
        view.subviews.forEach { subview in
            if subview.tag == 1234 {
                subview.removeFromSuperview()
            }
        }
        
        if tutorialStep == 1 {
            tutorialStep = 2
            tutorialTargetButton = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showCategoryMatchingTutorial()
            }
            return
        }
        
        // Apply proper category color to the target buttons if we're completing step 2
        if tutorialStep == 2, let category = targetCategory {
            let borderColor = Theme.categoryColors[category] ?? Theme.accentColor
            
            for button in targetButtons {
                button.layer.borderWidth = 4
                button.layer.borderColor = borderColor.cgColor
                button.backgroundColor = borderColor.withAlphaComponent(0.3)
                button.isEnabled = false
            }
        }
        
        UserDefaults.standard.set(true, forKey: "connections_tutorial_shown")
        isTutorialActive = false
        
        showTutorialCompletionMessage()
    }

    private func showCategoryMatchingTutorial() {
        var categoryButtons: [String: [UIButton]] = [:]
        var targetCategory: String?
        var targetButtons: [UIButton] = []
        
        for subview in gridContainerView.subviews {
            if let button = subview as? UIButton, let category = buttonCategories[button.tag] {
                if categoryButtons[category] == nil {
                    categoryButtons[category] = []
                }
                categoryButtons[category]?.append(button)
            }
        }
        
        for (category, buttons) in categoryButtons {
            if buttons.count == 4 {
                targetCategory = category
                targetButtons = buttons
                break
            }
        }
        
        if targetButtons.isEmpty, let (firstCategory, buttons) = categoryButtons.first {
            targetCategory = firstCategory
            targetButtons = Array(buttons.prefix(4))
        }
        
        guard targetButtons.count >= 4, let category = targetCategory else {
            completeTutorial()
            return
        }
        
        showCategorySelectionTutorial(category: category, buttons: targetButtons)
    }

    private func showCategorySelectionTutorial(category: String, buttons: [UIButton]) {
        for subview in gridContainerView.subviews {
            if let button = subview as? UIButton {
                button.isUserInteractionEnabled = true
                button.superview?.bringSubviewToFront(button)
            }
        }
        
        createTutorialOverlay()
        
        // Update the message to include the specific category
        let categoryName = category.capitalized
        createTutorialMessage("Find 4 \(categoryName) items\nLook for items that go in the \(categoryName) bin")
        
        for button in buttons {
            button.accessibilityIdentifier = "tutorialTargetButton"
            
            // Add pulsing effect to each target button
            highlightTutorialButton(button)
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTutorialButtonTapped(_:)),
            name: NSNotification.Name("TutorialButtonTapped"),
            object: nil
        )
    }

    private func highlightTutorialButton(_ button: UIButton) {
        let buttonFrame = button.convert(button.bounds, to: view)
        
        let pulseView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        pulseView.backgroundColor = Theme.accentColor
        pulseView.alpha = 0.3
        pulseView.layer.cornerRadius = 25
        pulseView.center = CGPoint(x: buttonFrame.midX, y: buttonFrame.midY)
        pulseView.isUserInteractionEnabled = false
        pulseView.tag = 1234
        view.addSubview(pulseView)
        
        button.superview?.bringSubviewToFront(button)
        
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseOut, .repeat, .autoreverse], animations: {
            pulseView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            pulseView.alpha = 0.5
        })
    }

    @objc private func handleTutorialButtonTapped(_ notification: Notification) {
        guard let button = notification.object as? UIButton else { return }
        
        // Check if the tapped button is actually a tutorial target button
        let isTargetButton = button.accessibilityIdentifier == "tutorialTargetButton"
        
        // Only show positive messages if the user tapped a target button
        if !isTargetButton {
            // For non-target buttons, show a hint message instead
            updateTutorialMessage("Try selecting one of the highlighted items")
            
            // Deselect the non-target button
            UIView.animate(withDuration: 0.2) {
                button.backgroundColor = Theme.cardColor
                button.transform = .identity
            }
            selectedButtons.remove(button)
            
            return
        }
        
        // From here, we know the user tapped a correct target button
        let selectedCount = selectedButtons.count
        
        // Only remove the pulse effect for the target button that was just tapped
        for subview in view.subviews {
            if subview.tag == 1234 {
                let pulseCenter = subview.center
                let buttonFrame = button.convert(button.bounds, to: view)
                let buttonCenter = CGPoint(x: buttonFrame.midX, y: buttonFrame.midY)
                
                // If this pulse is associated with the tapped button, remove it
                if hypot(pulseCenter.x - buttonCenter.x, pulseCenter.y - buttonCenter.y) < 30 {
                    subview.removeFromSuperview()
                }
            }
        }
        
        if selectedCount == 1 {
            updateTutorialMessage("Good! Now select 3 more items of the same category")
        } else if selectedCount == 2 {
            updateTutorialMessage("Keep going! Select 2 more items of the same category")
        } else if selectedCount == 3 {
            updateTutorialMessage("Almost there! Select 1 more item of the same category")
        } else if selectedCount == 4 {
            updateTutorialMessage("Great job! You've completed the category!")
            
            // Only remove all pulse effects when all 4 buttons are selected
            view.subviews.forEach { subview in
                if subview.tag == 1234 {
                    subview.removeFromSuperview()
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.completeTutorial()
            }
        }
    }

    // Add this method to the ConnectionsGameViewController class
    private func showWelcomeModal() {
        // Stop any running timer
        gameTimer?.invalidate()
        
        // Add a blocking overlay to prevent interaction with background elements
        let blockingOverlay = UIView(frame: view.bounds)
        blockingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.2) // Semi-transparent overlay
        blockingOverlay.isUserInteractionEnabled = true
        blockingOverlay.tag = 998
        view.addSubview(blockingOverlay)
        
        let welcomeContainerView = UIView()
        welcomeContainerView.translatesAutoresizingMaskIntoConstraints = false
        welcomeContainerView.backgroundColor = Theme.cardColor
        welcomeContainerView.layer.cornerRadius = 20
        welcomeContainerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        welcomeContainerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        welcomeContainerView.layer.shadowRadius = 20
        welcomeContainerView.layer.shadowOpacity = 1
        welcomeContainerView.alpha = 0
        welcomeContainerView.tag = 999
        view.addSubview(welcomeContainerView)
        
        NSLayoutConstraint.activate([
            welcomeContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            welcomeContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            welcomeContainerView.heightAnchor.constraint(equalToConstant: 530) // Increased height from 520 to 560
        ])
        
        // Icon
        let welcomeIcon = UIImageView()
        welcomeIcon.translatesAutoresizingMaskIntoConstraints = false
        welcomeIcon.contentMode = .scaleAspectFit
        welcomeIcon.tintColor = Theme.accentColor
        welcomeIcon.image = UIImage(systemName: "lightbulb.fill")
        welcomeContainerView.addSubview(welcomeIcon)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Welcome to Connections!"
        titleLabel.font = UIFont(name: "Sen-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = Theme.primaryText
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        welcomeContainerView.addSubview(titleLabel)
        
        // Message
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = "Group waste items into their correct categories: Landfill, Recycling, Compost, and Hazardous.\n\n• Select 4 items of the same category to complete a group\n• You have 4 attempts and 2 minutes to find all groups\n• Long press on items to see what they are"
        messageLabel.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = Theme.secondaryText
        messageLabel.textAlignment = .left
        messageLabel.numberOfLines = 0
        welcomeContainerView.addSubview(messageLabel)
        
        // Tutorial button
        let startTutorialButton = UIButton(type: .system)
        startTutorialButton.translatesAutoresizingMaskIntoConstraints = false
        startTutorialButton.setTitle("Start Tutorial", for: .normal)
        startTutorialButton.titleLabel?.font = UIFont(name: "Sen-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        startTutorialButton.setTitleColor(.white, for: .normal)
        startTutorialButton.backgroundColor = Theme.accentColor
        startTutorialButton.layer.cornerRadius = 25
        startTutorialButton.addTarget(self, action: #selector(startTutorialFromWelcome), for: .touchUpInside)
        welcomeContainerView.addSubview(startTutorialButton)
        
        // Skip tutorial button
        let skipTutorialButton = UIButton(type: .system)
        skipTutorialButton.translatesAutoresizingMaskIntoConstraints = false
        skipTutorialButton.setTitle("Skip Tutorial", for: .normal)
        skipTutorialButton.titleLabel?.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        skipTutorialButton.setTitleColor(Theme.secondaryText, for: .normal)
        skipTutorialButton.backgroundColor = .clear
        skipTutorialButton.addTarget(self, action: #selector(skipTutorialFromWelcome), for: .touchUpInside)
        welcomeContainerView.addSubview(skipTutorialButton)
        
        NSLayoutConstraint.activate([
            welcomeIcon.topAnchor.constraint(equalTo: welcomeContainerView.topAnchor, constant: 30),
            welcomeIcon.centerXAnchor.constraint(equalTo: welcomeContainerView.centerXAnchor),
            welcomeIcon.widthAnchor.constraint(equalToConstant: 60),
            welcomeIcon.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: welcomeIcon.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: welcomeContainerView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: welcomeContainerView.trailingAnchor, constant: -30),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: welcomeContainerView.leadingAnchor, constant: 30),
            messageLabel.trailingAnchor.constraint(equalTo: welcomeContainerView.trailingAnchor, constant: -30),
            
            // Add bottom constraint to message label
            messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: startTutorialButton.topAnchor, constant: -10),
            
            startTutorialButton.bottomAnchor.constraint(equalTo: skipTutorialButton.topAnchor, constant: -12),
            startTutorialButton.centerXAnchor.constraint(equalTo: welcomeContainerView.centerXAnchor),
            startTutorialButton.widthAnchor.constraint(equalToConstant: 240),
            startTutorialButton.heightAnchor.constraint(equalToConstant: 50),
            
            skipTutorialButton.bottomAnchor.constraint(equalTo: welcomeContainerView.bottomAnchor, constant: -24),
            skipTutorialButton.centerXAnchor.constraint(equalTo: welcomeContainerView.centerXAnchor),
            skipTutorialButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Animate in
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            welcomeContainerView.alpha = 1
        })
    }

    // Add these action methods for the buttons
    @objc private func startTutorialFromWelcome() {
        // Remove the welcome modal and blocking overlay
        for subview in view.subviews where subview.tag == 999 || subview.tag == 998 {
            UIView.animate(withDuration: 0.3, animations: {
                subview.alpha = 0
            }) { [weak self] _ in
                guard let self = self else { return }
                subview.removeFromSuperview()
                
                // Start the tutorial if it was the modal that was removed
                if subview.tag == 999 {
                    self.cleanupTutorialState()
                    self.startTutorial()
                }
            }
        }
    }

    @objc private func skipTutorialFromWelcome() {
        // Mark that the user has seen the tutorial (even if skipped)
        UserDefaults.standard.set(true, forKey: "connections_tutorial_shown")
        
        // Remove the welcome modal and blocking overlay
        for subview in view.subviews where subview.tag == 999 || subview.tag == 998 {
            UIView.animate(withDuration: 0.3, animations: {
                subview.alpha = 0
            }) { _ in
                subview.removeFromSuperview()
                // Start the game if it was the modal that was removed
                if subview.tag == 999 {
                    self.startTimer()
                }
            }
        }
    }
    
    private func showTutorialCompletionMessage() {
        // Add a blocking overlay to prevent interaction with background elements
        let blockingOverlay = UIView(frame: view.bounds)
        blockingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.2) // Semi-transparent overlay
        blockingOverlay.isUserInteractionEnabled = true
        blockingOverlay.tag = 998
        view.addSubview(blockingOverlay)
        
        // Create a styled modal similar to the help modal
        let completionContainerView = UIView()
        completionContainerView.translatesAutoresizingMaskIntoConstraints = false
        completionContainerView.backgroundColor = Theme.cardColor
        completionContainerView.layer.cornerRadius = 20
        completionContainerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        completionContainerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        completionContainerView.layer.shadowRadius = 20
        completionContainerView.layer.shadowOpacity = 1
        completionContainerView.alpha = 0
        completionContainerView.tag = 999
        view.addSubview(completionContainerView)
        
        NSLayoutConstraint.activate([
            completionContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completionContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            completionContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            completionContainerView.heightAnchor.constraint(equalToConstant: 320)
        ])
        
        // Success icon
        let completionIcon = UIImageView()
        completionIcon.translatesAutoresizingMaskIntoConstraints = false
        completionIcon.contentMode = .scaleAspectFit
        completionIcon.tintColor = Theme.accentColor
        completionIcon.image = UIImage(systemName: "checkmark.circle.fill")
        completionContainerView.addSubview(completionIcon)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Ready to Play!"
        titleLabel.font = UIFont(name: "Sen-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = Theme.primaryText
        titleLabel.textAlignment = .center
        completionContainerView.addSubview(titleLabel)
        
        // Message
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = "Great job! You've found one category. Now find the other three categories to complete the game!"
        messageLabel.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = Theme.secondaryText
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        completionContainerView.addSubview(messageLabel)
        
        // Let's play button
        let letsPlayButton = UIButton(type: .system)
        letsPlayButton.translatesAutoresizingMaskIntoConstraints = false
        letsPlayButton.setTitle("Let's Play", for: .normal)
        letsPlayButton.titleLabel?.font = UIFont(name: "Sen-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        letsPlayButton.setTitleColor(.white, for: .normal)
        letsPlayButton.backgroundColor = Theme.accentColor
        letsPlayButton.layer.cornerRadius = 25
        letsPlayButton.addTarget(self, action: #selector(dismissCompletionModal), for: .touchUpInside)
        completionContainerView.addSubview(letsPlayButton)
        
        NSLayoutConstraint.activate([
            completionIcon.topAnchor.constraint(equalTo: completionContainerView.topAnchor, constant: 30),
            completionIcon.centerXAnchor.constraint(equalTo: completionContainerView.centerXAnchor),
            completionIcon.widthAnchor.constraint(equalToConstant: 70),
            completionIcon.heightAnchor.constraint(equalToConstant: 70),
            
            titleLabel.topAnchor.constraint(equalTo: completionIcon.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: completionContainerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: completionContainerView.trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: completionContainerView.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: completionContainerView.trailingAnchor, constant: -24),
            
            letsPlayButton.bottomAnchor.constraint(equalTo: completionContainerView.bottomAnchor, constant: -30),
            letsPlayButton.centerXAnchor.constraint(equalTo: completionContainerView.centerXAnchor),
            letsPlayButton.widthAnchor.constraint(equalToConstant: 200),
            letsPlayButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Animate in
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            completionContainerView.alpha = 1
        })
    }

    @objc private func dismissCompletionModal() {
        // Remove both the completion modal and the blocking overlay
        for subview in view.subviews where subview.tag == 999 || subview.tag == 998 {
            UIView.animate(withDuration: 0.3, animations: {
                subview.alpha = 0
            }) { [weak self] _ in
                guard let self = self else { return }
                subview.removeFromSuperview()
                
                // Only start the timer when the modal is removed
                if subview.tag == 999 {
                    // Reset the timer and start it fresh
                    self.remainingTime = 120
                    self.timerLabel.text = "2:00"
                    self.gameTimer?.invalidate() // Cancel any existing timers
                    self.startTimer()
                }
            }
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let button = gesture.view as? UIButton else { return }
        
        if gesture.state == .began {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            if isTutorialActive && tutorialStep == 1 && button == tutorialTargetButton {
                NotificationCenter.default.post(name: NSNotification.Name("TutorialLongPressCompleted"), object: nil)
            }
            
            UIView.transition(with: button, duration: 0.3, options: .transitionFlipFromLeft, animations: {
                button.setImage(nil, for: .normal)
                if let imageName = self.buttonImages[button.tag] {
                    let originalDescription = WasteData.shared.getItemTitle(for: imageName)
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
}
