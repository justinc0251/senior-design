import UIKit

class QuizGameViewController: UIViewController {

    private var selectedOption: UIButton? = nil
    private var scoreLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var imageView: UIImageView!
    private var currentImage: String!
    private var titleLabel:UILabel!
    private var isAnswered: Bool = false
    private var imageQueue: [String] = []
    private var currentIndex: Int = 0

    private var nextQuestionButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        initializeImageQueue()
        currentImage = imageQueue[currentIndex]

        // 1) Image
        imageView = UIImageView(image: UIImage(named: currentImage))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: (view.frame.width - 100) / 2,
                                 y: 100,
                                 width: 100,
                                 height: 150)
        view.addSubview(imageView)

        titleLabel=UILabel()
        titleLabel.text = getItemTitle(for:currentImage)
        titleLabel.font=UIFont.boldSystemFont(ofSize:18)
        titleLabel.textAlignment = .center
        titleLabel.frame=CGRect(x:20,
                                y:imageView.frame.maxY+10,
                                width:view.frame.width-40,
                                height:30)
        view.addSubview(titleLabel)
        
        
        
        
        // 2) Description label
        descriptionLabel = UILabel()
        descriptionLabel.text = "Select an option to learn more."
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.frame = CGRect(x: 20,
                                        y: imageView.frame.maxY + 20,
                                        width: view.frame.width - 40,
                                        height: 60)
        descriptionLabel.alpha = 0 // hidden until they pick an answer
        view.addSubview(descriptionLabel)

        
        // 3) Four answer option buttons
        let recycleButton = createButton(title: "Recycle",
                                         frame: CGRect(x: 30,
                                                       y: descriptionLabel.frame.maxY + 40,
                                                       width: 150,
                                                       height: 80))
        let compostButton = createButton(title: "Compost",
                                         frame: CGRect(x: 210,
                                                       y: descriptionLabel.frame.maxY + 40,
                                                       width: 150,
                                                       height: 80))
        let landfillButton = createButton(title: "Landfill",
                                          frame: CGRect(x: 30,
                                                        y: descriptionLabel.frame.maxY + 140,
                                                        width: 150,
                                                        height: 80))
        let radioactiveButton = createButton(title: "Radioactive",
                                             frame: CGRect(x: 210,
                                                           y: descriptionLabel.frame.maxY + 140,
                                                           width: 150,
                                                           height: 80))

        view.addSubview(recycleButton)
        view.addSubview(compostButton)
        view.addSubview(landfillButton)
        view.addSubview(radioactiveButton)

        // 4) Score box
        let scoreBox = UIView()
        scoreBox.frame = CGRect(x: 100,
                                y: view.frame.height - 200,
                                width: view.frame.width - 200,
                                height: 100)
        scoreBox.backgroundColor = .lightGray
        scoreBox.layer.cornerRadius = 10
        view.addSubview(scoreBox)

        let scoreTitleLabel = UILabel()
        scoreTitleLabel.text = "Score"
        scoreTitleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        scoreTitleLabel.textAlignment = .center
        scoreTitleLabel.frame = CGRect(x: 0, y: 5,
                                       width: scoreBox.frame.width,
                                       height: 30)
        scoreBox.addSubview(scoreTitleLabel)

        scoreLabel = UILabel()
        scoreLabel.text = "0"
        scoreLabel.font = UIFont.systemFont(ofSize: 24)
        scoreLabel.textAlignment = .center
        scoreLabel.frame = CGRect(x: 0, y: 50,
                                  width: scoreBox.frame.width,
                                  height: 30)
        scoreBox.addSubview(scoreLabel)

        // 5) Next Question button, hidden by default
        nextQuestionButton = UIButton(type: .system)
        nextQuestionButton.setTitle("Next Question", for: .normal)
        nextQuestionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        nextQuestionButton.backgroundColor = .blue
        nextQuestionButton.setTitleColor(.white, for: .normal)
        nextQuestionButton.layer.cornerRadius = 8
        nextQuestionButton.frame = CGRect(x: scoreBox.frame.minX,
                                          y: scoreBox.frame.minY - 60,
                                          width: scoreBox.frame.width,
                                          height: 40)
        nextQuestionButton.addTarget(self,
                                     action: #selector(nextQuestionTapped),
                                     for: .touchUpInside)
        nextQuestionButton.isHidden = true     // Hide until question is answered
        view.addSubview(nextQuestionButton)
    }
    
    

    private func initializeImageQueue() {
        // Add whatever images you want to quiz on
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

    // MARK: - Game Logic
    
    @objc private func buttonTapped(_ sender: UIButton) {
        // Don’t allow re-answering if already answered
        guard !isAnswered else { return }
        guard let selectedTitle = sender.title(for: .normal) else { return }

        // Determine which option is correct for current image
        let correctOption = getCorrectOption()

        // Color all buttons red or green
        for subview in view.subviews {
            if let button = subview as? UIButton,
               let title = button.title(for: .normal) {
                if title == correctOption {
                    button.backgroundColor = .green
                } else if ["Recycle","Compost","Landfill","Radioactive"].contains(title) {
                    button.backgroundColor = .red
                }
            }
        }

        // If they chose the correct option, increment score
        if selectedTitle == correctOption {
            if let currentScore = Int(scoreLabel.text ?? "0") {
                scoreLabel.text = "\(currentScore + 1)"
            }
        }

        isAnswered = true

        // Show an explanation
        updateDescription(for: correctOption)

        // Now that they've answered, show the Next Question button
        nextQuestionButton.isHidden = false
    }

    private func getCorrectOption() -> String {
        switch currentImage {
        case "recycle1":  return "Recycle"
        case "compost1":  return "Compost"
        case "landfill1": return "Landfill"
        default:          return "Unknown"
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
            descriptionText = "Landfills are for waste that can't be recycled or composted."
        default:
            descriptionText = "Select an option to learn more."
        }

        descriptionLabel.text = descriptionText
        UIView.animate(withDuration: 0.5) {
            self.descriptionLabel.alpha = 1
        }
    }

    @objc private func nextQuestionTapped() {
        // Move to the next question only when user taps 'Next Question'
        loadNextQuestion()
    }
    
    
    private func getItemTitle(for imageName: String) ->String {
        switch imageName{
        case "recycle1": return "Piece of Paper"
        case "compost1": return "Apple"
        case "landfill1": return "Plastic Bag"
        default:        return "unknown Item"
    
        }
    }

    private func loadNextQuestion() {
        if currentIndex + 1 < imageQueue.count {
            currentIndex += 1
            currentImage = imageQueue[currentIndex]
            imageView.image = UIImage(named: currentImage)
            titleLabel.text=getItemTitle(for: currentImage)
            descriptionLabel.alpha = 0
            // Reset button colors
            for subview in view.subviews {
                if let button = subview as? UIButton,
                   ["Recycle","Compost","Landfill","Radioactive"].contains(button.title(for: .normal)) {
                    button.backgroundColor = .lightGray
                }
            }
            isAnswered = false
            nextQuestionButton.isHidden = true // Hide again until next answer is chosen
        } else {
            showFinalScore()
        }
    }

    private func showFinalScore() {
        // Clear the entire UI
        for subview in view.subviews {
            subview.removeFromSuperview()
        }

        let finalScoreLabel = UILabel()
        finalScoreLabel.text = "Game Over! Your final score is \(scoreLabel.text ?? "0")."
        finalScoreLabel.font = UIFont.boldSystemFont(ofSize: 24)
        finalScoreLabel.textAlignment = .center
        finalScoreLabel.numberOfLines = 0
        finalScoreLabel.frame = CGRect(
            x: 20,
            y: (view.frame.height - 100) / 2,
            width: view.frame.width - 40,
            height: 100
        )
        view.addSubview(finalScoreLabel)

        let replayButton = UIButton(type: .system)
        replayButton.setTitle("Replay", for: .normal)
        replayButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        replayButton.backgroundColor = .blue
        replayButton.setTitleColor(.white, for: .normal)
        replayButton.layer.cornerRadius = 10
        replayButton.frame = CGRect(
            x: (view.frame.width - 150) / 2,
            y: finalScoreLabel.frame.maxY + 20,
            width: 150,
            height: 50
        )
        replayButton.addTarget(self, action: #selector(replayGame), for: .touchUpInside)
        view.addSubview(replayButton)
    }

    @objc private func replayGame() {
        currentIndex = 0
        isAnswered = false
        scoreLabel.text = "0"
        // Clear subviews and rebuild
        view.subviews.forEach { $0.removeFromSuperview() }
        viewDidLoad()
    }
}
