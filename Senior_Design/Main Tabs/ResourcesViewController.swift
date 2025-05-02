import UIKit
import WebKit

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
    private let articles: [(topic: String, title: String, imageSystemName: String, content: String, link: String)] = [
        ("One-Earth", "Green teens: Understanding and promoting adolescents’ sustainable engagement,", "arrow.3.trianglepath", "One Earth provides research-driven insights into how sustainable behaviors can be encouraged among adolescents by aligning environmental actions with their core personal motives, such as the desire for independence, social belonging, and personal identity. Rather than relying solely on traditional messages about responsibility or future consequences, this approach emphasizes making sustainability meaningful and rewarding in young people's daily lives. The resource offers evidence-based strategies for educators, program designers, and advocates who want to foster lasting environmental engagement by connecting with the values that matter most to teens. It serves as a valuable guide for developing initiatives, educational materials, and games that aim to inspire a genuine, lifelong commitment to protecting the planet.", "https://doi.org/10.1016/j.oneear.2023.02.006" ),
        ("Waste Game", "Make Waste Fun Again! A Gamification Approach to Recycling", "leaf","Gamification strategies can significantly enhance recycling behavior by turning sustainable actions into engaging and rewarding experiences. By incorporating elements like feedback systems, achievements, point rewards, and social competition, recycling can be transformed from a routine task into a motivating and socially-driven activity. Focus group studies reveal that blending game mechanics with recycling initiatives helps bridge the gap between knowledge and action, making environmentally responsible behavior feel natural and satisfying. These findings offer valuable direction for anyone designing programs, educational materials, or interactive games that seek to build long-term commitment to sustainability through positive, playful reinforcement.", "https://doi.org/10.1007/978-3-030-53294-9_30"),
        ("How To Teach", "How Education Can Be Leveraged to Foster Adolescents’ Nature Connection", "trash", "Integrating nature into educational settings can significantly enhance adolescents' connection to the environment. By incorporating outdoor learning experiences, educators can boost students' motivation, academic performance, and overall well-being. Exposure to natural environments during schooling not only supports cognitive development but also fosters a lasting commitment to environmental stewardship. This approach underscores the importance of accessible green spaces in educational contexts, aiming to promote sustainability and address health disparities among youth.", "https://doi.org/10.1007/978-3-031-29257-6_5"),
        ("Practices", "Serious Practices for Interactive Waste Sorting Mini-game", "desktopcomputer", "Effective waste management is key to sustainable living, but many struggle with understanding waste classification. This study introduces a web-based serious game featuring interactive sorting quizzes created by users and AI to promote environmental sustainability. The game includes AI-generated feedback, a carbon credit system, and user-generated content to engage and educate players. Two user studies with 48 university students evaluated the game’s impact, showing it effectively enhanced understanding of sustainable waste management. The results demonstrate the potential of serious games to encourage environmental education and sustainable behaviors. By leveraging technology, such games can address environmental challenges and inspire sustainable practices.", "https://doi.org/10.1007/978-3-031-74138-8_11"),
        ("Eco-Quest Example Game", "ECO-QUEST: An Educational Game Designed to Impart Knowledge About Ecological Practices and Selective Waste Management", "number.circle", "ECO-QUEST is an educational game designed to enhance environmental awareness by engaging players in selective waste collection and recycling practices. Developed using the Game Design Document (GDD) methodology and the Startup Business Model Canvas, the game offers both single-player and multiplayer modes. Players navigate through timed challenges, sorting various waste types into appropriate bins, thereby learning about proper waste disposal in an interactive setting. The game's structure promotes critical thinking and problem-solving skills, aiming to foster sustainable behaviors and integrate environmental education into school curricula effectively.", "https://doi.org/10.1007/978-981-99-8248-6_35"),
        ("Gamification Influence", "Utilizing gamification to promote pro-sustainable behavior among information technology students", "fork.knife", "Gamification techniques in higher education offer a powerful way to inspire sustainable behavior by making environmental responsibility more engaging, competitive, and rewarding. Incorporating features like leaderboards, point systems, achievements, and interactive challenges into academic courses helps students connect with sustainability concepts on a deeper level while encouraging real-world application of eco-friendly habits. In this approach, students are not only learning about environmental issues but are actively motivated to take action, both within the classroom and in their daily lives. Gamified learning also fosters a sense of personal accountability, collaboration, and long-term commitment to environmental stewardship, demonstrating that educational environments can be a major force in shaping future sustainability leaders.", "https://doi.org/10.1007/s44217-024-00105-x"),
        ("Literature Review", "Determinants of adolescents’ pro-sustainable behavior: a systematic literature review using PRISMA", "fork.knife", "Climate change is a critical global issue with adolescents being among the most affected. To encourage environmentally responsible behavior among them, it is essential to identify the key factors that influence such actions. The paper states that while research shows many factors affecting adolescents’ pro-environmental behavior, these factors do not have common themes, and no study has comprehensively reviewed the scattered research on this topic. These findings can guide future researchers in expanding studies to developing countries and using mixed methods. Policymakers can also use the results to inspire adolescents to take part in climate change mitigation.", "https://doi.org/10.1007/s43621-024-00291-6"),
        ("Youth Attitudes", "Environmental Attitudes among Youth: How Much Do the Educational Characteristics of Parents and Young People Matter?", "fork.knife", "Motivation is a critical necessity for increasing and learning waste management techniques. This study provides insight on the growing phenomenon of education and its relation to environmental attitudes. This journal provides information regarding the importance of education from parents, students, and their surroundings. The journal reports the study of the importance of the environment to young students. Based on this study, they were able to determine how important education is to impacting the environment. This is important for our study, as motivation is a critical factor that will lead users to play our game. If there is a strict correlation of environmental importance to education from parents and their surroundings, then playing the game is also important for students to play.", "https://doi.org/10.3390/su151511921"),
        ("WasteApp Example", "How to Encourage Recycling Behaviour? The Case of WasteApp: A Gamified Mobile Application", "fork.knife", "This journal provides insight on the importance of mobile game applications for waste management at tourist attractions. Gamification is shown to be beneficial for teaching about sustainability as representative from the app (WasteApp). This journal teaches about the potential mobile game applications have in terms of teaching about behavior and more importantly why users would even play the game. The journal provides data on why people would want to play the app including the idea that risks cause more people to stray away. In total, this article provides strong evidence about the importance of using mobile game applications to teach more about waste management.", "https://doi.org/10.3390/su10051544"),
        ("Younger Vision on Sustainability", "Education for Sustainable Development: A Study in Adolescent Perception Changes Towards Sustainability Following a Strategic Planning-Based Intervention—The Young Persons’ Plan for the Planet Program", "fork.knife", "This journal talks about the United Nations SDGs which relate to waste management, and showed how young students could implement stem and research into sustainability. This article provides a sense of motivation for younger generations and that awareness and the need to take action is important to reduce problems like waste. This study provides data on how important it is to take action, and how this applies to waste management.", "https://doi.org/10.3390/su11205817")
    ]

    private let videos: [(topic: String, title: String, imageSystemName: String, link:String, content:String)] = [
        ("Tutorial", "Recycling Process Explained", "arrow.triangle.2.circlepath", "https://www.youtube.com/embed/6jQ7y_qQYUA", "The video Recycling for Kids | Recycling Plastic, Glass and Paper | Recycling for Children teaches young children about the importance of recycling and how they can help protect the environment. Through friendly cartoon animations and simple language, it explains why recycling matters by highlighting how it saves resources, reduces waste, and helps keep the Earth clean. The video shows kids how to identify recyclable materials like plastic, glass, paper, and metal, and emphasizes the importance of sorting them correctly into the appropriate bins. It walks through the recycling process, from collection to creating new products, and encourages kids to practice recycling at home. Overall, the video delivers a positive and motivational message that even small actions, like recycling daily, can make a big difference for the planet.")
//        ("DIY", "Upcycling Household Items", "hammer"),
//        ("Documentary", "The Journey of Waste", "map"),
//        ("Tutorial", "Home Composting System Setup", "house"),
//        ("Interview", "Waste Management Professionals", "person.2"),
//        ("Case Study", "Zero Waste Communities", "building.2")
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
                content: article.content,
                link: article.link
            )
            navigationController?.pushViewController(detailVC, animated: true)
        } else {
            let video = videos[indexPath.row]
            let detailVC = ModernVideoDetailViewController()
            detailVC.configure(
                title: video.title,
                topic: video.topic,
                iconName: video.imageSystemName,
                link: video.link,
                content:video.content
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
    private let linkLabel = UILabel()

    private var articleLink: String?
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

    func configure(title: String, topic: String, iconName: String, content: String, link: String) {
        self.articleTitle = title
        self.articleTopic = topic
        self.articleIconName = iconName
        self.articleContent = content
        self.articleLink = link


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

        linkLabel.font = UIFont(name: "Sen-Regular", size: 16)
        linkLabel.textColor = UIColor.systemBlue
        linkLabel.text = "View Source"
        linkLabel.numberOfLines = 1
        linkLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openLink))
        linkLabel.addGestureRecognizer(tapGesture)
        contentView.addSubview(linkLabel)
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
        linkLabel.translatesAutoresizingMaskIntoConstraints = false


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
            contentLabel.bottomAnchor.constraint(equalTo: linkLabel.topAnchor, constant: -24),

            linkLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 16),
            linkLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            linkLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            linkLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
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
        linkLabel.text = articleLink // Display the link text
    }

    @objc private func openLink() {
        guard let link = articleLink, let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - ModernVideoDetailViewController
class ModernVideoDetailViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let videoPlayerView = WKWebView() // Changed to WKWebView
    // Removed playButton
    private let topicLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let relatedVideosLabel = UILabel()
    private let relatedVideosStackView = UIStackView()

    private var videoContent:String?
    private var videoLink: String?
    // Removed articleContent
    private var videoTitle: String?
    private var videoTopic: String?
    private var videoIconName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        populateData()
    }

    func configure(title: String, topic: String, iconName: String, link:String, content:String) {
        self.videoTitle = title
        self.videoTopic = topic
        self.videoIconName = iconName
        self.videoLink=link
        self.videoContent=content
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
        // Allow inline playback
        videoPlayerView.configuration.allowsInlineMediaPlayback = true
        contentView.addSubview(videoPlayerView)

        // Removed playButton setup

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
        relatedVideosStackView.distribution = .fillEqually // Changed to fillEqually for consistent height
        contentView.addSubview(relatedVideosStackView)

        addRelatedVideos()
    }

    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        // Removed playButton constraints setup
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
            videoPlayerView.heightAnchor.constraint(equalTo: videoPlayerView.widthAnchor, multiplier: 9/16), // Standard 16:9 aspect ratio

            // Removed playButton constraints

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

        // Load video URL into WKWebView
        if let videoLink = videoLink, let url = URL(string: videoLink) {
            let request = URLRequest(url: url)
            videoPlayerView.load(request)
        } else {
            // Handle invalid URL case, maybe show an error or placeholder
            print("Invalid video URL")
        }

        descriptionLabel.text = videoContent
    }

    private func addRelatedVideos() {
        // Clear existing views if needed
        relatedVideosStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

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
        // Set explicit height for the card
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
            thumbnailView.widthAnchor.constraint(equalToConstant: 90), // Fixed width for thumbnail
            thumbnailView.heightAnchor.constraint(equalToConstant: 50), // Fixed height for thumbnail

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

    // Removed @objc private func playVideo() as it's no longer needed with WKWebView
}