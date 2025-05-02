import UIKit

class ResourcesViewController: UIViewController {
    
    // MARK: - Constants
    enum Constants {
        static let cornerRadius: CGFloat = 16
        static let standardPadding: CGFloat = 20
        static let cardHeight: CGFloat = 100
        static let tabHeight: CGFloat = 50
        static let headerHeight: CGFloat = 120
        static let accentColor = UIColor(red: 76/255, green: 187/255, blue: 123/255, alpha: 1.0)
        static let secondaryColor = UIColor(red: 87/255, green: 155/255, blue: 252/255, alpha: 1.0)
    }
    
    // MARK: - UI Components
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let tabContainer = UIView()
    private let tabUnderlineView = UIView()
    private let articlesButton = UIButton(type: .system)
    private let videosButton = UIButton(type: .system)
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Properties
    private var selectedTab: Int = 0 {
        didSet {
            updateTabSelection()
            tableView.reloadData()
        }
    }
    
    // MARK: - Sample Data
    private let articles: [(topic: String, title: String, imageSystemName: String, content: String)] = [
        ("Young-Generation", "Green teens: Understanding and promoting adolescents’ sustainable engagement,", "arrow.3.trianglepath", "This paper explores how teens are more likely to act sustainably if it impacts their independence or social status. These researchers developed a tool called the Sustainability Motive-Alignment Scale (SMAS) and tested this in different countries (e.g. the US, Netherlands, China, etc.). They found a positive correlation between cultural differences and attitudes towards sustainability."),
        ("Waste Game", "Make Waste Fun Again! A Gamification Approach to Recycling", "leaf","This paper uses focus groups to show that gamification could motivate people to recycle. It explores the idea that people prefer practical solutions and that using digital media is a good way to make learning about recycling fun. In addition, features such as rewards, achievements, and competition make the learning process more engaging."),
        ("How To Teach", "How Education Can Be Leveraged to Foster Adolescents’ Nature Connection", "trash", "This chapter discusses how outdoor learning improves motivation, school performance, and mental health. It bridges the argument to how the connection to nature encourages a lifetime of care for the environment and sustainability."),
        ("Practices", "Serious Practices for Interactive Waste Sorting Mini-game", "desktopcomputer", "Effective waste management is key to sustainable living, but many struggle with understanding waste classification. This study introduces a web-based serious game featuring interactive sorting quizzes created by users and AI to promote environmental sustainability. The game includes AI-generated feedback, a carbon credit system, and user-generated content to engage and educate players. Two user studies with 48 university students evaluated the game’s impact, showing it effectively enhanced understanding of sustainable waste management. The results demonstrate the potential of serious games to encourage environmental education and sustainable behaviors. By leveraging technology, such games can address environmental challenges and inspire sustainable practices."),
        ("Eco-Quest Example Game", "ECO-QUEST: An Educational Game Designed to Impart Knowledge About Ecological Practices and Selective Waste Management", "number.circle", "This study explores how using games can improve environmental education, focusing on solid waste management. It proposes creating an educational game as a tool for teachers to help students learn in a fun and meaningful way. The game aims to teach students the importance of sorting waste and recycling, raising their environmental awareness and encouraging better habits. The game is designed using a method called the Game Design Document (GDD) and planned with the Startup Business Model Canvas to ensure clear goals and structure. The research seeks to make environmental education more engaging by using digital technology to promote sustainability effectively in schools."),
        ("Gamification Influence", "Utilizing gamification to promote pro-sustainable behavior among information technology students", "fork.knife", "Higher education institutions are making progress in including sustainability in their programs. However, their research states that teaching methods for sustainable development need to focus more on hands-on and practical experiences to inspire real behavioral changes toward protecting the environment. This study evaluated how effective a gamified approach was in motivating IT students to adopt sustainable habits. Data was collected from 75 IT students through digital records and surveys during their English course. The results showed that gamification helped students embrace sustainable practices in their personal lives and future careers. It also significantly shifted their views, emphasizing the responsibility of individuals and employers in caring for the planet."),
        ("Literature Review", "Determinants of adolescents’ pro-sustainable behavior: a systematic literature review using PRISMA", "fork.knife", "Climate change is a critical global issue with adolescents being among the most affected. To encourage environmentally responsible behavior among them, it is essential to identify the key factors that influence such actions. The paper states that while research shows many factors affecting adolescents’ pro-environmental behavior, these factors do not have common themes, and no study has comprehensively reviewed the scattered research on this topic. These findings can guide future researchers in expanding studies to developing countries and using mixed methods. Policymakers can also use the results to inspire adolescents to take part in climate change mitigation."),
        ("Youth Attitudes", "Environmental Attitudes among Youth: How Much Do the Educational Characteristics of Parents and Young People Matter?", "fork.knife", "Motivation is a critical necessity for increasing and learning waste management techniques. This study provides insight on the growing phenomenon of education and its relation to environmental attitudes. This journal provides information regarding the importance of education from parents, students, and their surroundings. The journal reports the study of the importance of the environment to young students. Based on this study, they were able to determine how important education is to impacting the environment. This is important for our study, as motivation is a critical factor that will lead users to play our game. If there is a strict correlation of environmental importance to education from parents and their surroundings, then playing the game is also important for students to play."),
        ("WasteApp Example", "How to Encourage Recycling Behaviour? The Case of WasteApp: A Gamified Mobile Application", "fork.knife", "This journal provides insight on the importance of mobile game applications for waste management at tourist attractions. Gamification is shown to be beneficial for teaching about sustainability as representative from the app (WasteApp). This journal teaches about the potential mobile game applications have in terms of teaching about behavior and more importantly why users would even play the game. The journal provides data on why people would want to play the app including the idea that risks cause more people to stray away. In total, this article provides strong evidence about the importance of using mobile game applications to teach more about waste management."),
        ("Younger Vision on Sustainability", "Education for Sustainable Development: A Study in Adolescent Perception Changes Towards Sustainability Following a Strategic Planning-Based Intervention—The Young Persons’ Plan for the Planet Program", "fork.knife", "This journal talks about the United Nations SDGs which relate to waste management, and showed how young students could implement stem and research into sustainability. This article provides a sense of motivation for younger generations and that awareness and the need to take action is important to reduce problems like waste. This study provides data on how important it is to take action, and how this applies to waste management.")
    ]
    
    private let videos: [(topic: String, title: String, imageSystemName: String)] = [
        ("Tutorial", "Recycling Process Explained", "arrow.triangle.2.circlepath"),
        ("DIY", "Upcycling Household Items", "hammer"),
        ("Documentary", "The Journey of Waste", "map"),
        ("Tutorial", "Home Composting System Setup", "house"),
        ("Interview", "Waste Management Professionals", "person.2"),
        ("Case Study", "Zero Waste Communities", "building.2")
    ]
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // animateHeader()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        
        headerView.backgroundColor = .white
        headerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        headerView.layer.shadowOpacity = 1
        headerView.layer.shadowRadius = 8
        view.addSubview(headerView)
        
        titleLabel.text = "Learning Resources"
        titleLabel.font = UIFont(name: "Sen-Regular", size: 28)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        
        tabContainer.backgroundColor = .white
        view.addSubview(tabContainer)
        
        setupTabButtons()
        
        tabUnderlineView.backgroundColor = Constants.accentColor
        tabUnderlineView.layer.cornerRadius = 2
        tabContainer.addSubview(tabUnderlineView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        tableView.register(ModernResourceCell.self, forCellReuseIdentifier: "ResourceCell")
        view.addSubview(tableView)
        
        refreshControl.tintColor = Constants.accentColor
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupTabButtons() {
        articlesButton.setTitle("Articles", for: .normal)
        articlesButton.titleLabel?.font = UIFont(name: "Sen-Regular", size: 18)
        articlesButton.tintColor = Constants.accentColor
        articlesButton.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        articlesButton.tag = 0
        tabContainer.addSubview(articlesButton)
        
        videosButton.setTitle("Videos", for: .normal)
        videosButton.titleLabel?.font = UIFont(name: "Sen-Regular", size: 18)
        videosButton.tintColor = .lightGray
        videosButton.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        videosButton.tag = 1
        tabContainer.addSubview(videosButton)
    }
    
    private func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tabContainer.translatesAutoresizingMaskIntoConstraints = false
        articlesButton.translatesAutoresizingMaskIntoConstraints = false
        videosButton.translatesAutoresizingMaskIntoConstraints = false
        tabUnderlineView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: Constants.headerHeight),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Constants.standardPadding),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -Constants.standardPadding),
    
            tabContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tabContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabContainer.heightAnchor.constraint(equalToConstant: Constants.tabHeight),
            
            articlesButton.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor),
            articlesButton.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            articlesButton.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            articlesButton.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 0.5),
            
            videosButton.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor),
            videosButton.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            videosButton.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            videosButton.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 0.5),
            
            tabUnderlineView.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            tabUnderlineView.heightAnchor.constraint(equalToConstant: 4),
            tabUnderlineView.widthAnchor.constraint(equalToConstant: 100),
            tabUnderlineView.centerXAnchor.constraint(equalTo: articlesButton.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Animations
    private func animateHeader() {
        titleLabel.transform = CGAffineTransform(translationX: 0, y: -20)
        titleLabel.alpha = 0
        
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.titleLabel.transform = .identity
            self.titleLabel.alpha = 1
        })
    }
    
    private func updateTabSelection() {
        let targetButton = selectedTab == 0 ? articlesButton : videosButton
        let nonTargetButton = selectedTab == 0 ? videosButton : articlesButton
        
        targetButton.tintColor = Constants.accentColor
        nonTargetButton.tintColor = .lightGray
        
        UIView.animate(withDuration: 0.3) {
            self.tabUnderlineView.center.x = targetButton.center.x
        }
    }
    
    // MARK: - Actions
    @objc private func tabButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        selectedTab = sender.tag
    }
    
    @objc private func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ResourcesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTab == 0 ? articles.count : videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCell", for: indexPath) as? ModernResourceCell else {
            return UITableViewCell()
        }
        
        if selectedTab == 0 {
            let article = articles[indexPath.row]
            cell.configure(
                topic: article.topic,
                title: article.title,
                iconName: article.imageSystemName,
                isVideo: false
            )
        } else {
            let video = videos[indexPath.row]
            cell.configure(
                topic: video.topic,
                title: video.title,
                iconName: video.imageSystemName,
                isVideo: true
            )
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cardHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        if selectedTab == 0 {
            let article = articles[indexPath.row]
            let detailVC = ModernArticleDetailViewController()
            detailVC.configure(
                title: article.title,
                topic: article.topic,
                iconName: article.imageSystemName,
                content: article.content
            )
            navigationController?.pushViewController(detailVC, animated: true)
        } else {
            let video = videos[indexPath.row]
            let detailVC = ModernVideoDetailViewController()
            detailVC.configure(
                title: video.title,
                topic: video.topic,
                iconName: video.imageSystemName
            )
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// MARK: - ModernResourceCell
class ModernResourceCell: UITableViewCell {
    private let containerView = UIView()
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let videoIndicator = UIImageView()
    private let topicLabel = UILabel()
    private let titleLabel = UILabel()
    private let accessoryImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 1
        contentView.addSubview(containerView)
        
        iconContainer.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        iconContainer.layer.cornerRadius = 24
        containerView.addSubview(iconContainer)
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = ResourcesViewController.Constants.accentColor
        iconContainer.addSubview(iconImageView)
        
        videoIndicator.image = UIImage(systemName: "play.fill")
        videoIndicator.tintColor = .white
        videoIndicator.backgroundColor = ResourcesViewController.Constants.secondaryColor
        videoIndicator.layer.cornerRadius = 10
        videoIndicator.clipsToBounds = true
        videoIndicator.contentMode = .center
        videoIndicator.isHidden = true
        containerView.addSubview(videoIndicator)
        
        topicLabel.font = UIFont(name: "Sen-Regular", size: 14)
        topicLabel.textColor = ResourcesViewController.Constants.accentColor
        containerView.addSubview(topicLabel)
        
        titleLabel.font = UIFont(name: "Sen-Regular", size: 18)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2
        containerView.addSubview(titleLabel)
        
        accessoryImageView.image = UIImage(systemName: "chevron.right")
        accessoryImageView.tintColor = .lightGray
        accessoryImageView.contentMode = .scaleAspectFit
        containerView.addSubview(accessoryImageView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        videoIndicator.translatesAutoresizingMaskIntoConstraints = false
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            videoIndicator.widthAnchor.constraint(equalToConstant: 20),
            videoIndicator.heightAnchor.constraint(equalToConstant: 20),
            videoIndicator.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 6),
            videoIndicator.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 6),
            
            topicLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            topicLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            topicLabel.trailingAnchor.constraint(equalTo: accessoryImageView.leadingAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: topicLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: accessoryImageView.leadingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16),
            
            accessoryImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            accessoryImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            accessoryImageView.widthAnchor.constraint(equalToConstant: 16),
            accessoryImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(topic: String, title: String, iconName: String, isVideo: Bool) {
        topicLabel.text = topic
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: iconName)
        videoIndicator.isHidden = !isVideo
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        topicLabel.text = nil
        titleLabel.text = nil
        iconImageView.image = nil
        videoIndicator.isHidden = true
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.containerView.layer.shadowOpacity = highlighted ? 0.3 : 1.0
        }
    }
}

// MARK: - ModernArticleDetailViewController
class ModernArticleDetailViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerView = UIView()
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let topicLabel = UILabel()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let dividerView = UIView()
    
    private var articleTitle: String?
    private var articleTopic: String?
    private var articleIconName: String?
    private var articleContent: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        populateData()
    }
    
    func configure(title: String, topic: String, iconName: String, content: String) {
        self.articleTitle = title
        self.articleTopic = topic
        self.articleIconName = iconName
        self.articleContent = content


    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        contentView.backgroundColor = .clear
        scrollView.addSubview(contentView)
        
        headerView.backgroundColor = .white
        headerView.layer.cornerRadius = 16
        headerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        headerView.layer.shadowRadius = 8
        headerView.layer.shadowOpacity = 1
        contentView.addSubview(headerView)
        
        iconContainer.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        iconContainer.layer.cornerRadius = 36
        headerView.addSubview(iconContainer)
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = ResourcesViewController.Constants.accentColor
        iconContainer.addSubview(iconImageView)
        
        topicLabel.font = UIFont(name: "Sen-Regular", size: 18)
        topicLabel.textColor = ResourcesViewController.Constants.accentColor
        headerView.addSubview(topicLabel)
        
        titleLabel.font = UIFont(name: "Sen-Regular", size: 24)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        headerView.addSubview(titleLabel)
        
        dividerView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        contentView.addSubview(dividerView)
        
        contentLabel.font = UIFont(name: "Sen-Regular", size: 16)
        contentLabel.textColor = .darkGray
        contentLabel.numberOfLines = 0
        contentView.addSubview(contentLabel)
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            iconContainer.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            iconContainer.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            iconContainer.widthAnchor.constraint(equalToConstant: 72),
            iconContainer.heightAnchor.constraint(equalToConstant: 72),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            topicLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            topicLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            topicLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            
            titleLabel.topAnchor.constraint(equalTo: topicLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -24),
            
            dividerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            
            contentLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 24),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func populateData() {
        self.title = articleTitle
        topicLabel.text = articleTopic
        titleLabel.text = articleTitle
        
        if let iconName = articleIconName {
            iconImageView.image = UIImage(systemName: iconName)
        }
        
        contentLabel.text = articleContent
    }
}

// MARK: - ModernVideoDetailViewController
class ModernVideoDetailViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let videoPlayerView = UIView()
    private let playButton = UIButton(type: .system)
    private let topicLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let relatedVideosLabel = UILabel()
    private let relatedVideosStackView = UIStackView()
    
    private var articleContent: String?
    private var videoTitle: String?
    private var videoTopic: String?
    private var videoIconName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        populateData()
    }
    
    func configure(title: String, topic: String, iconName: String) {
        self.videoTitle = title
        self.videoTopic = topic
        self.videoIconName = iconName
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        contentView.backgroundColor = .clear
        scrollView.addSubview(contentView)
        
        videoPlayerView.backgroundColor = UIColor.darkGray
        videoPlayerView.layer.cornerRadius = 16
        videoPlayerView.clipsToBounds = true
        contentView.addSubview(videoPlayerView)
        
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tintColor = .white
        playButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        playButton.layer.cornerRadius = 30
        playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        videoPlayerView.addSubview(playButton)
        
        topicLabel.font = UIFont(name: "Sen-Regular", size: 18)
        topicLabel.textColor = ResourcesViewController.Constants.accentColor
        contentView.addSubview(topicLabel)
        
        titleLabel.font = UIFont(name: "Sen-Regular", size: 24)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        
        descriptionLabel.font = UIFont(name: "Sen-Regular", size: 16)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
        
        relatedVideosLabel.font = UIFont(name: "Sen-Regular", size: 20)
        relatedVideosLabel.textColor = .black
        relatedVideosLabel.text = "Related Videos"
        contentView.addSubview(relatedVideosLabel)
        
        relatedVideosStackView.axis = .vertical
        relatedVideosStackView.spacing = 12
        relatedVideosStackView.distribution = .fillEqually
        contentView.addSubview(relatedVideosStackView)
        
        addRelatedVideos()
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        relatedVideosLabel.translatesAutoresizingMaskIntoConstraints = false
        relatedVideosStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            videoPlayerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            videoPlayerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            videoPlayerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            videoPlayerView.heightAnchor.constraint(equalTo: videoPlayerView.widthAnchor, multiplier: 9/16),
            
            playButton.centerXAnchor.constraint(equalTo: videoPlayerView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: videoPlayerView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 60),
            playButton.heightAnchor.constraint(equalToConstant: 60),
            
            topicLabel.topAnchor.constraint(equalTo: videoPlayerView.bottomAnchor, constant: 24),
            topicLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            topicLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            titleLabel.topAnchor.constraint(equalTo: topicLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            relatedVideosLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            relatedVideosLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            relatedVideosLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            relatedVideosStackView.topAnchor.constraint(equalTo: relatedVideosLabel.bottomAnchor, constant: 16),
            relatedVideosStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            relatedVideosStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            relatedVideosStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func populateData() {
        self.title = videoTitle
        topicLabel.text = videoTopic
        titleLabel.text = videoTitle
        
        if let iconName = videoIconName, let image = UIImage(systemName: iconName) {
            let thumbnailImageView = UIImageView(image: image)
            thumbnailImageView.contentMode = .scaleAspectFit
            thumbnailImageView.tintColor = .white
            thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
            videoPlayerView.addSubview(thumbnailImageView)
            
            NSLayoutConstraint.activate([
                thumbnailImageView.centerXAnchor.constraint(equalTo: videoPlayerView.centerXAnchor),
                thumbnailImageView.centerYAnchor.constraint(equalTo: videoPlayerView.centerYAnchor, constant: -20),
                thumbnailImageView.widthAnchor.constraint(equalToConstant: 60),
                thumbnailImageView.heightAnchor.constraint(equalToConstant: 60)
            ])
        }
        
        descriptionLabel.text = "This video explores effective waste management strategies and their impact on environmental sustainability. Learn practical tips for reducing waste in your daily life and contributing to a healthier planet.\n\nThe content covers various waste reduction techniques, recycling methods, composting basics, and how to properly handle hazardous materials. It also discusses the environmental benefits of proper waste management, including reduced landfill usage, decreased pollution, and conservation of natural resources."
    }
    
    private func addRelatedVideos() {
        let relatedVideoTitles = [
            "Waste Sorting Best Practices",
            "Home Composting Guide",
            "Upcycling Household Items"
        ]
        
        for title in relatedVideoTitles {
            let videoCard = createRelatedVideoCard(title: title)
            relatedVideosStackView.addArrangedSubview(videoCard)
        }
    }
    
    private func createRelatedVideoCard(title: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 6
        card.layer.shadowOpacity = 1
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let thumbnailView = UIView()
        thumbnailView.backgroundColor = UIColor.lightGray
        thumbnailView.layer.cornerRadius = 8
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(thumbnailView)
        
        let playIcon = UIImageView(image: UIImage(systemName: "play.fill"))
        playIcon.tintColor = .white
        playIcon.contentMode = .scaleAspectFit
        playIcon.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.addSubview(playIcon)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont(name: "Sen-Regular", size: 16)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            thumbnailView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            thumbnailView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            thumbnailView.widthAnchor.constraint(equalToConstant: 90),
            thumbnailView.heightAnchor.constraint(equalToConstant: 50),
            
            playIcon.centerXAnchor.constraint(equalTo: thumbnailView.centerXAnchor),
            playIcon.centerYAnchor.constraint(equalTo: thumbnailView.centerYAnchor),
            playIcon.widthAnchor.constraint(equalToConstant: 16),
            playIcon.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        
        return card
    }
    
    @objc private func playVideo() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let alert = UIAlertController(title: "Video Playback", message: "Video playback would start here in a real application.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}