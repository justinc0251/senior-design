import UIKit

class OnboardingViewController: UIViewController {
    
    // MARK: - Properties
    
    // Update the pages array with your new image names
    private let pages = [
        OnboardingPage(image: "page1", 
                    title: "Welcome to Litter-acy!", 
                    description: "Learn, play, and make a positive impact on our environment"),
        OnboardingPage(image: "page2", 
                    title: "Test Your Knowledge", 
                    description: "Challenge yourself with fun games about recycling, composting, and waste management"),
        OnboardingPage(image: "page3", 
                    title: "Track Your Progress", 
                    description: "Earn points, climb the leaderboard, and see your environmental impact grow")
    ]
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = Theme.accentColor
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
        return pageControl
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(OnboardingCell.self, forCellWithReuseIdentifier: "OnboardingCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont(name: "Sen-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = Theme.accentColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = UIFont(name: "Sen-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        button.setTitleColor(UIColor(white: 0.4, alpha: 1.0), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    
    // MARK: - Theme
    
    enum Theme {
        static let backgroundColor = UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1.0)
        static let accentColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
        static let textColor = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1.0)
        static let secondaryTextColor = UIColor(red: 100/255, green: 100/255, blue: 110/255, alpha: 1.0)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Add targets to buttons here, where 'self' is available
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = Theme.backgroundColor
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(continueButton)
        view.addSubview(skipButton)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -30),
            
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -10),
            continueButton.widthAnchor.constraint(equalToConstant: 200),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        let indexPath = IndexPath(item: sender.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        updateButtonTitle()
    }
    
    @objc private func continueTapped() {
        if pageControl.currentPage == pages.count - 1 {
            navigateToLogin()
        } else {
            let nextPage = pageControl.currentPage + 1
            pageControl.currentPage = nextPage
            let indexPath = IndexPath(item: nextPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            updateButtonTitle()
        }
    }
    
    @objc private func skipTapped() {
        navigateToLogin()
    }
    
    private func updateButtonTitle() {
        let isLastPage = pageControl.currentPage == pages.count - 1
        continueButton.setTitle(isLastPage ? "Get Started" : "Continue", for: .normal)
        
        UIView.animate(withDuration: 0.2) {
            self.continueButton.backgroundColor = isLastPage ? UIColor(red: 255/255, green: 184/255, blue: 76/255, alpha: 1.0) : Theme.accentColor
        }
    }
    
    private func navigateToLogin() {
        // Mark that onboarding has been completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        let loginVC = LoginViewController()
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            let navigationController = UINavigationController(rootViewController: loginVC)
            sceneDelegate.window?.rootViewController = navigationController
        }
    }
}

// MARK: - Collection View Delegate & DataSource

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCell
        cell.configure(with: pages[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        let currentPage = Int(scrollView.contentOffset.x / width)
        pageControl.currentPage = currentPage
        updateButtonTitle()
    }
}

// MARK: - Onboarding Cell

class OnboardingCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Sen-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = OnboardingViewController.Theme.textColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Sen-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)
        label.textColor = OnboardingViewController.Theme.secondaryTextColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80), // Changed from 40 to 80
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.45), // Slightly reduced from 0.5
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30)
        ])
    }
    
    func configure(with page: OnboardingPage) {
        imageView.image = UIImage(named: page.image)
        titleLabel.text = page.title
        descriptionLabel.text = page.description
    }
}

// MARK: - Data Model

struct OnboardingPage {
    let image: String
    let title: String
    let description: String
}
