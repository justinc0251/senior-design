import UIKit

class ViewController: UIViewController {

    private var selectedOption: UIButton? = nil
    private var scoreLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var imageView: UIImageView!
    private var currentImage: String!
    private var isAnswered: Bool = false // Track if the question is already answered
    private var imageQueue: [String] = [] // Queue of images for questions
    private var currentIndex: Int = 0 // Track current question index

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Initialize image queue with three questions
        initializeImageQueue()

        // Add image on top
        currentImage = imageQueue[currentIndex]
        imageView = UIImageView(image: UIImage(named: currentImage))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: (view.frame.width - 100) / 2, y: 100, width: 100, height: 150)
        view.addSubview(imageView)

        // Add description label
        descriptionLabel = UILabel()
        descriptionLabel.text = "Select an option to learn more."
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.frame = CGRect(x: 20, y: imageView.frame.maxY + 20, width: view.frame.width - 40, height: 60)
        descriptionLabel.alpha = 0 // Initially hidden
        view.addSubview(descriptionLabel)

        // Add buttons
        let recycleButton = createButton(title: "Recycle", frame: CGRect(x: 50, y: descriptionLabel.frame.maxY + 40, width: 150, height: 80))
        let compostButton = createButton(title: "Compost", frame: CGRect(x: 230, y: descriptionLabel.frame.maxY + 40, width: 150, height: 80))
        let landfillButton = createButton(title: "Landfill", frame: CGRect(x: 50, y: descriptionLabel.frame.maxY + 140, width: 150, height: 80))
        let radioactiveButton = createButton(title: "Radioactive", frame: CGRect(x: 230, y: descriptionLabel.frame.maxY + 140, width: 150, height: 80))

        // Add buttons to view
        view.addSubview(recycleButton)
        view.addSubview(compostButton)
        view.addSubview(landfillButton)
        view.addSubview(radioactiveButton)

        // Add score box
        let scoreBox = UIView()
        scoreBox.frame = CGRect(x: 50, y: view.frame.height - 150, width: view.frame.width - 100, height: 100)
        scoreBox.backgroundColor = .lightGray
        scoreBox.layer.cornerRadius = 10
        view.addSubview(scoreBox)

        // Add score label
        let scoreTitleLabel = UILabel()
        scoreTitleLabel.text = "Score"
        scoreTitleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        scoreTitleLabel.textAlignment = .center
        scoreTitleLabel.frame = CGRect(x: 0, y: 10, width: scoreBox.frame.width, height: 30)
        scoreBox.addSubview(scoreTitleLabel)

        // Add points label
        scoreLabel = UILabel()
        scoreLabel.text = "0"
        scoreLabel.font = UIFont.systemFont(ofSize: 24)
        scoreLabel.textAlignment = .center
        scoreLabel.frame = CGRect(x: 0, y: 50, width: scoreBox.frame.width, height: 30)
        scoreBox.addSubview(scoreLabel)
    }

    private func initializeImageQueue() {
        // Set the image queue with three images
        imageQueue = ["recycle1", "compost1", "landfill1"]
    }

    private func createButton(title: String, frame: CGRect) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .lightGray
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.frame = frame
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        guard !isAnswered else { return } // Prevent multiple clicks after an answer is selected

        guard let selectedTitle = sender.title(for: .normal) else { return }

        // Determine the correct option
        let correctOption = getCorrectOption()

        // Highlight all options
        for subview in view.subviews {
            if let button = subview as? UIButton, let title = button.title(for: .normal) {
                if title == correctOption {
                    button.backgroundColor = .green
                } else {
                    button.backgroundColor = .red
                }
            }
        }

        // Update the score only if the selection is correct
        if selectedTitle == correctOption {
            if let currentScore = Int(scoreLabel.text ?? "0") {
                scoreLabel.text = "\(currentScore + 1)"
            }
        }

        // Mark the question as answered
        isAnswered = true

        // Update the description
        updateDescription(for: correctOption)

        // Move to the next question after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loadNextQuestion()
        }
    }

    private func getCorrectOption() -> String {
        switch currentImage {
        case "recycle1": return "Recycle"
        case "compost1": return "Compost"
        case "landfill1": return "Landfill"
        default: return "Unknown"
        }
    }

    private func updateDescription(for option: String) {
        var descriptionText = ""
        switch option {
        case "Recycle":
            descriptionText = "Recycling helps reduce waste and conserve resources."
        case "Compost":
            descriptionText = "Composting turns organic waste into nutrient-rich soil."
        case "Landfill":
            descriptionText = "Landfills are used to dispose of waste that cannot be recycled or composted."
        default:
            descriptionText = "Select an option to learn more."
        }

        descriptionLabel.text = descriptionText

        UIView.animate(withDuration: 0.5) {
            self.descriptionLabel.alpha = 1
        }
    }

    private func loadNextQuestion() {
        // Check if there are more questions
        if currentIndex + 1 < imageQueue.count {
            currentIndex += 1
            currentImage = imageQueue[currentIndex]
            imageView.image = UIImage(named: currentImage)
            descriptionLabel.alpha = 0 // Hide description

            // Reset buttons
            for subview in view.subviews {
                if let button = subview as? UIButton {
                    button.backgroundColor = .lightGray
                }
            }

            isAnswered = false
        } else {
            // Show the description for the last question briefly before showing the final score
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showFinalScore()
            }
        }
    }

    private func showFinalScore() {
        // Hide all views
        for subview in view.subviews {
            subview.removeFromSuperview()
        }

        // Display final score
        let finalScoreLabel = UILabel()
        finalScoreLabel.text = "Game Over! Your final score is \(scoreLabel.text ?? "0")."
        finalScoreLabel.font = UIFont.boldSystemFont(ofSize: 24)
        finalScoreLabel.textAlignment = .center
        finalScoreLabel.numberOfLines = 0
        finalScoreLabel.frame = CGRect(x: 20, y: (view.frame.height - 100) / 2, width: view.frame.width - 40, height: 100)
        view.addSubview(finalScoreLabel)

        // Add replay button
        let replayButton = UIButton(type: .system)
        replayButton.setTitle("Replay", for: .normal)
        replayButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        replayButton.backgroundColor = .blue
        replayButton.setTitleColor(.white, for: .normal)
        replayButton.layer.cornerRadius = 10
        replayButton.frame = CGRect(x: (view.frame.width - 150) / 2, y: finalScoreLabel.frame.maxY + 20, width: 150, height: 50)
        replayButton.addTarget(self, action: #selector(replayGame), for: .touchUpInside)
        view.addSubview(replayButton)
    }

    @objc private func replayGame() {
        // Reset the game
        currentIndex = 0
        isAnswered = false
        scoreLabel.text = "0"
        view.subviews.forEach { $0.removeFromSuperview() } // Remove all subviews
        viewDidLoad() // Reload the initial game view
    }
}

#Preview {
    ViewController()
}
