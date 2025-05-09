import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class QuizGameViewController: UIViewController {
    
    // MARK: - Properties
    
    private var selectedOption: UIButton?
    private var isAnswered: Bool = false
    private var imageQueue: [String] = []
    private var currentIndex: Int = 0
    private var currentImage: String!
    private var currentScore: Int = 0
    
    // MARK: - Theme Colors
    
    private enum Theme {
        static let backgroundColor = UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1.0)
        static let cardColor = UIColor.white
        static let primaryText = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1.0)
        static let secondaryText = UIColor(red: 100/255, green: 100/255, blue: 110/255, alpha: 1.0)
        static let accentColor = UIColor(red: 255/255, green: 184/255, blue: 76/255, alpha: 1.0)
        
        static let correctColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
        static let incorrectColor = UIColor(red: 235/255, green: 87/255, blue: 87/255, alpha: 1.0)
        
        static let optionColors: [String: UIColor] = [
            "Recycle": UIColor(red: 87/255, green: 155/255, blue: 252/255, alpha: 1.0),
            "Compost": UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0),
            "Landfill": UIColor(red: 163/255, green: 126/255, blue: 73/255, alpha: 1.0),
            "Hazardous": UIColor(red: 235/255, green: 87/255, blue: 87/255, alpha: 1.0)
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
    
    private let gameTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Trivia"
        label.font = UIFont(name: "Sen-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = Theme.primaryText
        label.textAlignment = .center
        return label
    }()
    
    private let gameSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Get your score out of 10 questions"
        label.font = UIFont(name: "Sen-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        label.textColor = Theme.secondaryText
        label.textAlignment = .center
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.cardColor
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 1
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Sen-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = Theme.primaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Where does this item belong?"
        label.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.textColor = Theme.secondaryText
        label.textAlignment = .center
        return label
    }()
    
    private let imageContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.backgroundColor
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let descriptionContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.backgroundColor.withAlphaComponent(0.8)
        view.layer.cornerRadius = 12
        view.alpha = 0 // Initially hidden
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.textColor = Theme.primaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let optionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let row1StackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let row2StackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let scoreContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 245/255, alpha: 1.0)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Score: 0"
        label.font = UIFont(name: "Sen-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = Theme.primaryText
        label.textAlignment = .center
        label.layer.cornerRadius = 12 // Not visible on UILabel directly
        return label
    }()
    
    private let nextQuestionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Next Question", for: .normal)
        button.titleLabel?.font = UIFont(name: "Sen-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = Theme.correctColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = Theme.correctColor.withAlphaComponent(0.4).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 1
        button.isHidden = true // Initially hidden
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initializeImageQueue()
        loadQuestion()
        
        tabBarController?.tabBar.isHidden = true // Hide tab bar for game focus
        
        // Customize navigation bar
        navigationItem.title = "" // Clear default title if large titles are used
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = Theme.accentColor // Back button color
        headerView.backgroundColor = .clear // Make header transparent
        headerView.layer.shadowOpacity = 0 // Remove shadow from header
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false // Restore tab bar when leaving
        stopGame()
    }
    
    private func stopGame() {
        // Clear current state
        selectedOption = nil
        isAnswered = false
        imageQueue.removeAll()
        currentIndex = 0
        currentImage = nil
        currentScore = 0
        
        // Remove dynamically added result views or overlays if needed
        for subview in view.subviews {
            if subview.tag == 999 || String(describing: subview).contains("resultsContainer") { // Tag used for result overlay
                subview.removeFromSuperview()
            }
        }
    }

    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = Theme.backgroundColor
        
        // Clear previous buttons if any (important for replay)
        row1StackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        row2StackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        containerView.addSubview(descriptionContainer) // Add description container
        descriptionContainer.addSubview(descriptionLabel) // Add description label to its container
        containerView.addSubview(optionsStackView)
        optionsStackView.addArrangedSubview(row1StackView)
        optionsStackView.addArrangedSubview(row2StackView)
        
        // Create and add option buttons
        let recycleButton = createOptionButton(title: "Recycle", color: Theme.optionColors["Recycle"] ?? .blue)
        let compostButton = createOptionButton(title: "Compost", color: Theme.optionColors["Compost"] ?? .green)
        let landfillButton = createOptionButton(title: "Landfill", color: Theme.optionColors["Landfill"] ?? .brown)
        let hazardousButton = createOptionButton(title: "Hazardous", color: Theme.optionColors["Hazardous"] ?? .red)
        
        row1StackView.addArrangedSubview(recycleButton)
        row1StackView.addArrangedSubview(compostButton)
        row2StackView.addArrangedSubview(landfillButton)
        row2StackView.addArrangedSubview(hazardousButton)
        
        containerView.addSubview(scoreLabel) // Add score label to container
        
        view.addSubview(nextQuestionButton) // Add next question button to main view
        nextQuestionButton.isHidden = false // Ensure it's not hidden initially
        nextQuestionButton.alpha = 1 // Ensure it's visible
        nextQuestionButton.addTarget(self, action: #selector(nextQuestionTapped), for: .touchUpInside)
        
        setupHeader()
        setupConstraints()
    }
    
    private func setupHeader() {
        view.addSubview(headerView)
        headerView.addSubview(gameTitleLabel)
        headerView.addSubview(gameSubtitleLabel)
        
        // Get status bar height dynamically
        let statusBarHeight: CGFloat = {
            if #available(iOS 13.0, *) {
                return view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            } else {
                return UIApplication.shared.statusBarFrame.height
            }
        }()
        
        let topMargin = statusBarHeight + 100 // Adjust as needed for spacing below status bar
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: topMargin),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            // headerView.heightAnchor.constraint(equalToConstant: 60), // Adjust height as needed
            
            gameTitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            gameTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            gameSubtitleLabel.topAnchor.constraint(equalTo: gameTitleLabel.bottomAnchor, constant: 4),
            gameSubtitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            gameSubtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor) // Ensure headerView wraps content
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container View constraints
            containerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16), // Adjust bottom constraint
            
            // Title and Subtitle Label constraints
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Image Container and Image View constraints
            imageContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            imageContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            imageContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            imageContainerView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3), // Adjust height
            
            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: imageContainerView.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: imageContainerView.heightAnchor, multiplier: 0.8),

            // Description Container and Label (initially hidden)
            descriptionContainer.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            descriptionContainer.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            descriptionContainer.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            descriptionContainer.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: descriptionContainer.topAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionContainer.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionContainer.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionContainer.bottomAnchor, constant: -16),
            
            // Options Stack View constraints
            optionsStackView.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 24),
            optionsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            optionsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            // optionsStackView.heightAnchor.constraint(equalToConstant: 132), // 2 rows * 60 height + 12 spacing
            
            // Score Label constraints
            scoreLabel.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 20),
            scoreLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Next Question Button constraints
            nextQuestionButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            nextQuestionButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 16), // Below score
            nextQuestionButton.widthAnchor.constraint(equalToConstant: 200),
            nextQuestionButton.heightAnchor.constraint(equalToConstant: 50),
            nextQuestionButton.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16) // Ensure it stays within container
        ])
    }
    
    private func createOptionButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "Sen-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = color.withAlphaComponent(0.2) // Light background
        button.setTitleColor(color, for: .normal) // Text color matching the category
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = color.withAlphaComponent(0.3).cgColor // Subtle border
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true // Set fixed height for buttons
        
        button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    // MARK: - Game Logic
    
    private func initializeImageQueue() {
        var tempQueue: [String] = []
        
        let allCategories = ["recycle", "compost", "landfill", "hazard"]
        
        // Ensure we get a mix, aiming for ~2-3 per category for 10 questions
        for category in allCategories {
            if let categoryImages = WasteData.shared.categories[category] {
                let shuffledImages = categoryImages.shuffled()
                // Take up to 3 images per category to ensure variety if one category has few items
                let count = min(3, categoryImages.count)
                tempQueue.append(contentsOf: shuffledImages.prefix(count))
            }
        }
        
        // Shuffle all collected items and take the first 10 for the quiz
        imageQueue = Array(tempQueue.shuffled().prefix(10))
        
        // Ensure we have at least one image to start
        if imageQueue.isEmpty {
            // Fallback: if somehow no images are loaded, add a default or handle error
            print("Error: Image queue is empty after initialization.")
            // Potentially add a default placeholder image or show an error
            // For now, let's prevent a crash if currentImage is accessed when nil
            if let firstRecycle = WasteData.shared.categories["recycle"]?.first {
                 imageQueue.append(firstRecycle)
            } else {
                // Handle the case where even fallback isn't possible (though unlikely with current WasteData)
                 gameDidEndPrematurely("Could not load quiz questions.")
                 return
            }
        }
        currentImage = imageQueue[currentIndex] // Set the first image
    }
    
    private func loadQuestion() {
        titleLabel.text = getItemTitle(for: currentImage)
        imageView.image = UIImage(named: currentImage)
        
        // Reset UI elements for the new question
        descriptionContainer.alpha = 0 // Hide description initially
        nextQuestionButton.isHidden = true // Hide next button
        isAnswered = false // Reset answered state
        
        // Reset button appearances
        for stackView in [row1StackView, row2StackView] {
            for case let button as UIButton in stackView.arrangedSubviews {
                // Remove any X marks from previous incorrect answers
                button.subviews.forEach { subview in
                    if subview.tag == 888 { // Tag used for X mark
                        subview.removeFromSuperview()
                    }
                }
                
                let title = button.title(for: .normal) ?? ""
                let color = Theme.optionColors[title] ?? .gray // Get original color
                
                // Animate back to default state
                UIView.animate(withDuration: 0.3) {
                    button.backgroundColor = color.withAlphaComponent(0.2)
                    button.setTitleColor(color, for: .normal)
                    button.layer.borderColor = color.withAlphaComponent(0.3).cgColor
                    button.transform = .identity // Reset any scaling
                }
            }
        }
    }
    
    @objc private func optionButtonTapped(_ sender: UIButton) {
        guard !isAnswered, let selectedTitle = sender.title(for: .normal) else { return }
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactOccurred()
        
        isAnswered = true
        selectedOption = sender
        
        let correctOption = getCorrectOption()
        
        // Update button appearances based on correctness
        for stackView in [row1StackView, row2StackView] {
            for case let button as UIButton in stackView.arrangedSubviews {
                if let title = button.title(for: .normal) {
                    if title == correctOption {
                        // Correct answer button
                        UIView.animate(withDuration: 0.3) {
                            button.backgroundColor = Theme.correctColor
                            button.setTitleColor(.white, for: .normal)
                            button.layer.borderColor = Theme.correctColor.cgColor
                            button.transform = CGAffineTransform(scaleX: 1.05, y: 1.05) // Emphasize
                        }
                    } else {
                        // Incorrect or other option buttons
                        UIView.animate(withDuration: 0.3) {
                            button.backgroundColor = Theme.incorrectColor.withAlphaComponent(0.15)
                            button.setTitleColor(Theme.incorrectColor, for: .normal)
                            button.layer.borderColor = Theme.incorrectColor.withAlphaComponent(0.3).cgColor
                            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) // De-emphasize
                        }
                    }
                }
            }
        }
        
        // If selected option was incorrect, add an X mark
        if selectedTitle != correctOption {
            addXMark(to: sender)
        }
        
        // Update score if correct
        if selectedTitle == correctOption {
            currentScore += 1
            scoreLabel.text = "Score: \(currentScore)"
        
            // Animate score label for feedback
            UIView.animate(withDuration: 0.3, animations: {
                self.scoreLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    self.scoreLabel.transform = .identity
                }
            }
            
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
        }
        
        // Update and show the description for the correct category of the current item
        updateDescriptionForItem() // Changed from updateDescription(for: correctOption)
        
        // Show next question button
        nextQuestionButton.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.nextQuestionButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.nextQuestionButton.transform = .identity
            }
        }
    }

    private func addXMark(to button: UIButton) {
        // Remove previous X mark if any
        button.subviews.forEach { subview in
            if subview.tag == 888 { // Tag used for X mark
                subview.removeFromSuperview()
            }
        }
        
        let xMarkView = UIImageView(image: UIImage(systemName: "xmark"))
        xMarkView.tintColor = Theme.incorrectColor // Use a visible color
        xMarkView.contentMode = .scaleAspectFit
        xMarkView.translatesAutoresizingMaskIntoConstraints = false
        xMarkView.alpha = 0 // Start transparent for animation
        xMarkView.tag = 888 // Tag to identify for removal
        xMarkView.tintColor = Theme.incorrectColor.withAlphaComponent(0.7) // Slightly transparent X
        
        button.addSubview(xMarkView) // Add to the button itself
        
        NSLayoutConstraint.activate([
            xMarkView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            xMarkView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            xMarkView.widthAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.5),
            xMarkView.heightAnchor.constraint(equalTo: button.heightAnchor, multiplier: 0.5)
        ])
        
        UIView.animate(withDuration: 0.2) {
            xMarkView.alpha = 1 // Fade in
        }
    }
    
    private func getCorrectOption() -> String {
        if let category = WasteData.shared.getCategory(for: currentImage) {
            return WasteData.shared.getDisplayNameForCategory(category)
        }
        return "Unknown" // Fallback
    }
    
    private func getItemTitle(for imageName: String) -> String {
        return WasteData.shared.getItemTitle(for: imageName)
    }
    
    private func updateDescriptionForItem() {
        let explanation = WasteData.shared.getItemExplanation(for: currentImage)
        descriptionLabel.text = explanation
        
        UIView.animate(withDuration: 0.5) {
            self.descriptionContainer.alpha = 1
        }
    }
    
    @objc private func nextQuestionTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Animate button press
        UIView.animate(withDuration: 0.1) {
            self.nextQuestionButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.nextQuestionButton.transform = .identity
            } completion: { _ in
                // Load the next question after animation
                self.loadNextQuestion()
            }
        }
    }
    
    private func loadNextQuestion() {
        if currentIndex + 1 < imageQueue.count {
            // Transition to the next question
            UIView.transition(with: containerView, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.currentIndex += 1
                self.currentImage = self.imageQueue[self.currentIndex]
                self.loadQuestion() // This will reset UI for the new question
            }, completion: nil)
        } else {
            // Game finished, show final score
            showFinalScore()
        }
    }
    
    private func gameDidEndPrematurely(_ message: String) {
        // Invalidate timers, stop game logic, etc.
        stopGame() // Call your existing stopGame or a similar cleanup method

        // Show an alert or a specific UI state indicating the problem
        let alert = UIAlertController(title: "Game Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true) // Go back or to a safe screen
        }))
        present(alert, animated: true)
    }

    private func showFinalScore() {
        UserDefaults.standard.set(true, forKey: "game_2_completed") // Mark game as completed

        GameHistoryManager.shared.saveGameHistory(gameName: "Trivia", score: currentScore) // Save score
        
        // Animate out the current game UI
        UIView.animate(withDuration: 0.5) {
            self.containerView.alpha = 0
            self.scoreLabel.alpha = 0
            self.nextQuestionButton.alpha = 0
        } completion: { _ in
            // Remove old UI elements
            self.containerView.removeFromSuperview()
            self.scoreLabel.removeFromSuperview()
            self.nextQuestionButton.removeFromSuperview()
            
            // Create and configure the results view
            let resultsContainer = UIView()
            resultsContainer.translatesAutoresizingMaskIntoConstraints = false
            resultsContainer.backgroundColor = Theme.cardColor
            resultsContainer.layer.cornerRadius = 20
            resultsContainer.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
            resultsContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
            resultsContainer.layer.shadowRadius = 12
            resultsContainer.layer.shadowOpacity = 1
            resultsContainer.alpha = 0 // Start transparent for animation
            
            let completionImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            completionImageView.translatesAutoresizingMaskIntoConstraints = false
            completionImageView.contentMode = .scaleAspectFit
            completionImageView.tintColor = Theme.correctColor
            
            let finalScoreTitleLabel = UILabel() // Renamed to avoid conflict
            finalScoreTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            finalScoreTitleLabel.text = "Game Over!"
            finalScoreTitleLabel.font = UIFont(name: "Sen-Bold", size: 30) ?? UIFont.systemFont(ofSize: 30, weight: .bold)
            finalScoreTitleLabel.textColor = Theme.primaryText
            finalScoreTitleLabel.textAlignment = .center
            
            let scoreDetailsLabel = UILabel()
            scoreDetailsLabel.translatesAutoresizingMaskIntoConstraints = false
            scoreDetailsLabel.text = "Your final score is \(self.currentScore) out of \(self.imageQueue.count)"
            scoreDetailsLabel.font = UIFont(name: "Sen-Regular", size: 20) ?? UIFont.systemFont(ofSize: 20)
            scoreDetailsLabel.textColor = Theme.secondaryText
            scoreDetailsLabel.textAlignment = .center
            
            let replayButton = UIButton(type: .system)
            replayButton.translatesAutoresizingMaskIntoConstraints = false
            replayButton.setTitle("Play Again", for: .normal)
            replayButton.titleLabel?.font = UIFont(name: "Sen-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
            replayButton.backgroundColor = Theme.correctColor
            replayButton.setTitleColor(.white, for: .normal)
            replayButton.layer.cornerRadius = 25
            replayButton.layer.shadowColor = Theme.correctColor.withAlphaComponent(0.4).cgColor
            replayButton.layer.shadowOffset = CGSize(width: 0, height: 3)
            replayButton.layer.shadowRadius = 6
            replayButton.layer.shadowOpacity = 1
            replayButton.addTarget(self, action: #selector(self.replayGame), for: .touchUpInside)
            
            resultsContainer.addSubview(completionImageView)
            resultsContainer.addSubview(finalScoreTitleLabel)
            resultsContainer.addSubview(scoreDetailsLabel)
            resultsContainer.addSubview(replayButton)
            
            self.view.addSubview(resultsContainer) // Add to the main view
            
            // Constraints for the results container and its elements
            NSLayoutConstraint.activate([
                resultsContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                resultsContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                resultsContainer.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.85),
                resultsContainer.heightAnchor.constraint(equalToConstant: 350), // Adjust height as needed
                resultsContainer.bottomAnchor.constraint(lessThanOrEqualTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),


                completionImageView.topAnchor.constraint(equalTo: resultsContainer.topAnchor, constant: 30),
                completionImageView.centerXAnchor.constraint(equalTo: resultsContainer.centerXAnchor),
                completionImageView.widthAnchor.constraint(equalToConstant: 80),
                completionImageView.heightAnchor.constraint(equalToConstant: 80),
                
                finalScoreTitleLabel.topAnchor.constraint(equalTo: completionImageView.bottomAnchor, constant: 20),
                finalScoreTitleLabel.leadingAnchor.constraint(equalTo: resultsContainer.leadingAnchor, constant: 20),
                finalScoreTitleLabel.trailingAnchor.constraint(equalTo: resultsContainer.trailingAnchor, constant: -20),
                
                scoreDetailsLabel.topAnchor.constraint(equalTo: finalScoreTitleLabel.bottomAnchor, constant: 16),
                scoreDetailsLabel.leadingAnchor.constraint(equalTo: resultsContainer.leadingAnchor, constant: 20),
                scoreDetailsLabel.trailingAnchor.constraint(equalTo: resultsContainer.trailingAnchor, constant: -20),
                
                replayButton.bottomAnchor.constraint(equalTo: resultsContainer.bottomAnchor, constant: -30),
                replayButton.centerXAnchor.constraint(equalTo: resultsContainer.centerXAnchor),
                replayButton.widthAnchor.constraint(equalToConstant: 200),
                replayButton.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            // Animate in the results container
            UIView.animate(withDuration: 0.5) {
                resultsContainer.alpha = 1
            }
        }
    }
    
    @objc private func replayGame() {
        // Animate button press for replay button
        if let button = view.subviews.last?.subviews.last as? UIButton { // Assuming replayButton is the last subview of resultsContainer
            UIView.animate(withDuration: 0.1) {
                button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            } completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    button.transform = .identity
                } completion: { _ in
                    // Remove results container
                    if let resultsContainer = self.view.subviews.last { // Assuming resultsContainer is the last subview of the main view
                        UIView.animate(withDuration: 0.3, animations: {
                            resultsContainer.alpha = 0
                        }, completion: { _ in
                            resultsContainer.removeFromSuperview()
                            
                            // Remove old game UI elements (important if they weren't fully removed before)
                            self.containerView.removeFromSuperview()
                            self.scoreLabel.removeFromSuperview() // It was part of containerView, but good to be explicit
                            self.nextQuestionButton.removeFromSuperview() // It was part of main view
                            
                            // Reset game state
                            self.currentIndex = 0
                            self.currentScore = 0
                            self.isAnswered = false
                            self.initializeImageQueue() // Re-initialize questions
                            if !self.imageQueue.isEmpty {
                                 self.currentImage = self.imageQueue[self.currentIndex]
                            } else {
                                 self.gameDidEndPrematurely("Failed to reload questions for replay.")
                                 return
                            }
                           
                            
                            // Setup UI for new game
                            self.setupUI() // This will recreate containerView and its children
                            self.loadQuestion() // Load the first question
                            
                            // Reset navigation bar (if needed, though it's mostly static for this game)
                            self.navigationItem.title = ""
                            self.navigationController?.navigationBar.prefersLargeTitles = true
                            self.navigationController?.navigationBar.tintColor = Theme.accentColor
                            
                            // Animate in the new game container
                            self.containerView.alpha = 0 // Ensure it starts transparent
                            UIView.animate(withDuration: 0.3) {
                                self.containerView.alpha = 1
                            }
                        })
                    }
                }
            }
        }
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
            } else {
                print("Score successfully updated!")
            }
        }
    }
}