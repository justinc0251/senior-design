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
        view.alpha = 0
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
        label.layer.cornerRadius = 12
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
        button.isHidden = true
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initializeImageQueue()
        loadQuestion()
        
        navigationItem.title = ""
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = Theme.accentColor
        headerView.backgroundColor = .clear
        headerView.layer.shadowOpacity = 0
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = Theme.backgroundColor
        
        row1StackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        row2StackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        containerView.addSubview(descriptionContainer)
        descriptionContainer.addSubview(descriptionLabel)
        containerView.addSubview(optionsStackView)
        optionsStackView.addArrangedSubview(row1StackView)
        optionsStackView.addArrangedSubview(row2StackView)
        
        let recycleButton = createOptionButton(title: "Recycle", color: Theme.optionColors["Recycle"] ?? .blue)
        let compostButton = createOptionButton(title: "Compost", color: Theme.optionColors["Compost"] ?? .green)
        let landfillButton = createOptionButton(title: "Landfill", color: Theme.optionColors["Landfill"] ?? .brown)
        let hazardousButton = createOptionButton(title: "Hazardous", color: Theme.optionColors["Hazardous"] ?? .red)
        
        row1StackView.addArrangedSubview(recycleButton)
        row1StackView.addArrangedSubview(compostButton)
        row2StackView.addArrangedSubview(landfillButton)
        row2StackView.addArrangedSubview(hazardousButton)
        
        containerView.addSubview(scoreLabel)
        
        view.addSubview(nextQuestionButton)
        nextQuestionButton.isHidden = false
        nextQuestionButton.alpha = 1
        nextQuestionButton.addTarget(self, action: #selector(nextQuestionTapped), for: .touchUpInside)
        
        setupHeader()
        setupConstraints()
    }
    
    private func setupHeader() {
        view.addSubview(headerView)
        headerView.addSubview(gameTitleLabel)
        headerView.addSubview(gameSubtitleLabel)
        
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
            
            gameTitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            gameTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            gameSubtitleLabel.topAnchor.constraint(equalTo: gameTitleLabel.bottomAnchor, constant: 4),
            gameSubtitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            gameSubtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            imageContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            imageContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            imageContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            imageContainerView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3),
            
            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: imageContainerView.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: imageContainerView.heightAnchor, multiplier: 0.8),
            
            descriptionContainer.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            descriptionContainer.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            descriptionContainer.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            descriptionContainer.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionContainer.topAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionContainer.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionContainer.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionContainer.bottomAnchor, constant: -16),
            
            optionsStackView.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 24),
            optionsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            optionsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            scoreLabel.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 20),
            scoreLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            nextQuestionButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            nextQuestionButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 16),
            nextQuestionButton.widthAnchor.constraint(equalToConstant: 200),
            nextQuestionButton.heightAnchor.constraint(equalToConstant: 50),
            nextQuestionButton.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func createOptionButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "Sen-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = color.withAlphaComponent(0.2)
        button.setTitleColor(color, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    // MARK: - Game Logic
    
    private func initializeImageQueue() {
        var tempQueue: [String] = []
        
        let allCategories = ["recycle", "compost", "landfill", "hazard"]
        
        for category in allCategories {
            if let categoryImages = WasteData.shared.categories[category] {
                let shuffledImages = categoryImages.shuffled()
                let count = min(3, categoryImages.count)
                tempQueue.append(contentsOf: shuffledImages.prefix(count))
            }
        }
        
        imageQueue = Array(tempQueue.shuffled().prefix(10))
        currentImage = imageQueue[currentIndex]
    }
    
    private func loadQuestion() {
        titleLabel.text = getItemTitle(for: currentImage)
        imageView.image = UIImage(named: currentImage)
        
        descriptionContainer.alpha = 0
        nextQuestionButton.isHidden = true
        isAnswered = false
        
        for stackView in [row1StackView, row2StackView] {
            for case let button as UIButton in stackView.arrangedSubviews {
                button.subviews.forEach { subview in
                    if subview.tag == 888 {
                        subview.removeFromSuperview()
                    }
                }
                
                let title = button.title(for: .normal) ?? ""
                let color = Theme.optionColors[title] ?? .gray
                
                UIView.animate(withDuration: 0.3) {
                    button.backgroundColor = color.withAlphaComponent(0.2)
                    button.setTitleColor(color, for: .normal)
                    button.layer.borderColor = color.withAlphaComponent(0.3).cgColor
                    button.transform = .identity
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
        
        for stackView in [row1StackView, row2StackView] {
            for case let button as UIButton in stackView.arrangedSubviews {
                if let title = button.title(for: .normal) {
                    if title == correctOption {
                        UIView.animate(withDuration: 0.3) {
                            button.backgroundColor = Theme.correctColor
                            button.setTitleColor(.white, for: .normal)
                            button.layer.borderColor = Theme.correctColor.cgColor
                            button.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                        }
                    } else {
                        UIView.animate(withDuration: 0.3) {
                            button.backgroundColor = Theme.incorrectColor.withAlphaComponent(0.15)
                            button.setTitleColor(Theme.incorrectColor, for: .normal)
                            button.layer.borderColor = Theme.incorrectColor.withAlphaComponent(0.3).cgColor
                            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                        }
                    }
                }
            }
        }
        
        if selectedTitle != correctOption {
            addXMark(to: sender)
        }
        
        if selectedTitle == correctOption {
            currentScore += 1
            scoreLabel.text = "Score: \(currentScore)"
        
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
        
        updateDescription(for: correctOption)
        
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
        button.subviews.forEach { subview in
            if subview.tag == 888 {
                subview.removeFromSuperview()
            }
        }
        
        let xMarkView = UIImageView(image: UIImage(systemName: "xmark"))
        xMarkView.tintColor = Theme.incorrectColor
        xMarkView.contentMode = .scaleAspectFit
        xMarkView.translatesAutoresizingMaskIntoConstraints = false
        xMarkView.alpha = 0
        xMarkView.tag = 888
        xMarkView.tintColor = Theme.incorrectColor.withAlphaComponent(0.7)
        
        button.addSubview(xMarkView)
        
        NSLayoutConstraint.activate([
            xMarkView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            xMarkView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            xMarkView.widthAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.5),
            xMarkView.heightAnchor.constraint(equalTo: button.heightAnchor, multiplier: 0.5)
        ])
        
        UIView.animate(withDuration: 0.2) {
            xMarkView.alpha = 1
        }
    }
    
    private func getCorrectOption() -> String {
        if let category = WasteData.shared.getCategory(for: currentImage) {
            return WasteData.shared.getDisplayNameForCategory(category)
        }
        return "Unknown"
    }
    
    private func getItemTitle(for imageName: String) -> String {
        return WasteData.shared.getItemTitle(for: imageName)
    }
    
    private func updateDescription(for option: String) {
        var descriptionText = ""
        
        switch option {
        case "Recycle":
            descriptionText = "This item can be recycled. Recycling helps conserve resources and reduces waste in landfills."
        case "Compost":
            descriptionText = "This item is compostable and can break down naturally to create nutrient-rich soil."
        case "Landfill":
            descriptionText = "This item should go to landfill as it cannot be recycled or composted in standard programs."
        case "Hazardous":
            descriptionText = "This is hazardous waste and requires special disposal. Do not place in regular trash or recycling."
        default:
            descriptionText = "Select an option to learn more."
        }
        
        descriptionLabel.text = descriptionText
        
        UIView.animate(withDuration: 0.5) {
            self.descriptionContainer.alpha = 1
        }
    }
    
    @objc private func nextQuestionTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.1) {
            self.nextQuestionButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.nextQuestionButton.transform = .identity
            } completion: { _ in
                self.loadNextQuestion()
            }
        }
    }
    
    private func loadNextQuestion() {
        if currentIndex + 1 < imageQueue.count {
            UIView.transition(with: containerView, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.currentIndex += 1
                self.currentImage = self.imageQueue[self.currentIndex]
                self.loadQuestion()
            }, completion: nil)
        } else {
            showFinalScore()
        }
    }
    
    private func showFinalScore() {
        UserDefaults.standard.set(true, forKey: "game_2_completed")

        GameHistoryManager.shared.saveGameHistory(gameName: "Trivia", score: currentScore)
        
        UIView.animate(withDuration: 0.5) {
            self.containerView.alpha = 0
            self.scoreLabel.alpha = 0
            self.nextQuestionButton.alpha = 0
        } completion: { _ in
            self.containerView.removeFromSuperview()
            self.scoreLabel.removeFromSuperview()
            self.nextQuestionButton.removeFromSuperview()
            
            let resultsContainer = UIView()
            resultsContainer.translatesAutoresizingMaskIntoConstraints = false
            resultsContainer.backgroundColor = Theme.cardColor
            resultsContainer.layer.cornerRadius = 20
            resultsContainer.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
            resultsContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
            resultsContainer.layer.shadowRadius = 12
            resultsContainer.layer.shadowOpacity = 1
            resultsContainer.alpha = 0
            
            let completionImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            completionImageView.translatesAutoresizingMaskIntoConstraints = false
            completionImageView.contentMode = .scaleAspectFit
            completionImageView.tintColor = Theme.correctColor
            
            let finalScoreLabel = UILabel()
            finalScoreLabel.translatesAutoresizingMaskIntoConstraints = false
            finalScoreLabel.text = "Game Over!"
            finalScoreLabel.font = UIFont(name: "Sen-Bold", size: 30) ?? UIFont.systemFont(ofSize: 30, weight: .bold)
            finalScoreLabel.textColor = Theme.primaryText
            finalScoreLabel.textAlignment = .center
            
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
            resultsContainer.addSubview(finalScoreLabel)
            resultsContainer.addSubview(scoreDetailsLabel)
            resultsContainer.addSubview(replayButton)
            
            self.view.addSubview(resultsContainer)
            
            NSLayoutConstraint.activate([
                resultsContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                resultsContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                resultsContainer.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.85),
                resultsContainer.heightAnchor.constraint(equalToConstant: 350),
                resultsContainer.bottomAnchor.constraint(lessThanOrEqualTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                
                completionImageView.topAnchor.constraint(equalTo: resultsContainer.topAnchor, constant: 30),
                completionImageView.centerXAnchor.constraint(equalTo: resultsContainer.centerXAnchor),
                completionImageView.widthAnchor.constraint(equalToConstant: 80),
                completionImageView.heightAnchor.constraint(equalToConstant: 80),
                
                finalScoreLabel.topAnchor.constraint(equalTo: completionImageView.bottomAnchor, constant: 20),
                finalScoreLabel.leadingAnchor.constraint(equalTo: resultsContainer.leadingAnchor, constant: 20),
                finalScoreLabel.trailingAnchor.constraint(equalTo: resultsContainer.trailingAnchor, constant: -20),
                
                scoreDetailsLabel.topAnchor.constraint(equalTo: finalScoreLabel.bottomAnchor, constant: 16),
                scoreDetailsLabel.leadingAnchor.constraint(equalTo: resultsContainer.leadingAnchor, constant: 20),
                scoreDetailsLabel.trailingAnchor.constraint(equalTo: resultsContainer.trailingAnchor, constant: -20),
                
                replayButton.bottomAnchor.constraint(equalTo: resultsContainer.bottomAnchor, constant: -30),
                replayButton.centerXAnchor.constraint(equalTo: resultsContainer.centerXAnchor),
                replayButton.widthAnchor.constraint(equalToConstant: 200),
                replayButton.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            UIView.animate(withDuration: 0.5) {
                resultsContainer.alpha = 1
            }
        }
    }
    
    @objc private func replayGame() {
        if let button = view.subviews.last?.subviews.last as? UIButton {
            UIView.animate(withDuration: 0.1) {
                button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            } completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    button.transform = .identity
                } completion: { _ in
                    if let resultsContainer = self.view.subviews.last {
                        UIView.animate(withDuration: 0.3, animations: {
                            resultsContainer.alpha = 0
                        }, completion: { _ in
                            resultsContainer.removeFromSuperview()
                            
                            self.containerView.removeFromSuperview()
                            self.scoreLabel.removeFromSuperview()
                            self.nextQuestionButton.removeFromSuperview()
                            
                            self.currentIndex = 0
                            self.currentScore = 0
                            self.isAnswered = false
                            self.initializeImageQueue()
                            self.currentImage = self.imageQueue[self.currentIndex]
                            
                            self.setupUI()
                            self.loadQuestion()
                            
                            self.navigationItem.title = ""
                            self.navigationController?.navigationBar.prefersLargeTitles = true
                            self.navigationController?.navigationBar.tintColor = Theme.accentColor
                            
                            self.containerView.alpha = 0
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
