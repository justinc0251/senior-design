import UIKit

class ResourcesViewController: UIViewController {
    
    // UI Components
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let segmentedControl = UISegmentedControl(items: ["Articles", "Videos"])
    private let tableView = UITableView()
    private let underlineView = UIView()
    
    // Mock Data
    private let articles: [(topic: String, title: String)] = [
        ("Article Topic (Recycling, Landfill, etc.)", "Article Title"),
        ("Article Topic", "Article Title"),
        ("Article Topic", "Article Title"),
        ("Article Topic", "Article Title"),
        ("Article Topic", "Article Title"),
        ("Article Topic", "Article Title")
    ]
    
    private let videos: [(topic: String, title: String)] = [
        ("Video Topic (Recycling, Landfill, etc.)", "Video Title"),
        ("Video Topic", "Video Title"),
        ("Video Topic", "Video Title"),
        ("Video Topic", "Video Title"),
        ("Video Topic", "Video Title"),
        ("Video Topic", "Video Title")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        // Header with title
        headerView.backgroundColor = .white
        view.addSubview(headerView)
        
        // Title label
        titleLabel.text = "Waste Management\nResources"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        headerView.addSubview(titleLabel)
        
        // Segmented control
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmentedControl.backgroundColor = .clear
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(red: 141/255, green: 212/255, blue: 109/255, alpha: 1),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)
        ], for: .selected)
        segmentedControl.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segmentedControl.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        view.addSubview(segmentedControl)
        
        // Underline for selected segment
        underlineView.backgroundColor = UIColor(red: 141/255, green: 212/255, blue: 109/255, alpha: 1)
        view.addSubview(underlineView)
        
        // TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ArticleCell.self, forCellReuseIdentifier: "ArticleCell")
        tableView.register(VideoCell.self, forCellReuseIdentifier: "VideoCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Title
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Segmented Control
            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 44),
            
            // Underline
            underlineView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: 2),
            underlineView.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor, multiplier: 0.5),
            underlineView.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor),
            
            // TableView
            tableView.topAnchor.constraint(equalTo: underlineView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        // Animate underline
        UIView.animate(withDuration: 0.3) {
            if sender.selectedSegmentIndex == 0 {
                self.underlineView.transform = .identity
            } else {
                self.underlineView.transform = CGAffineTransform(translationX: self.view.frame.width / 2, y: 0)
            }
        }
        
        // Reload data based on selected segment
        tableView.reloadData()
    }
}

extension ResourcesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentedControl.selectedSegmentIndex == 0 ? articles.count : videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 0 {
            // Articles tab
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as? ArticleCell else {
                return UITableViewCell()
            }
            
            let article = articles[indexPath.row]
            cell.configure(topic: article.topic, title: article.title)
            return cell
        } else {
            // Videos tab
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as? VideoCell else {
                return UITableViewCell()
            }
            
            let video = videos[indexPath.row]
            cell.configure(topic: video.topic, title: video.title)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            // Article selected
            let article = articles[indexPath.row]
            
            let detailVC = ArticleDetailViewController()
            detailVC.articleTitle = article.title
            detailVC.articleTopic = article.topic
            navigationController?.pushViewController(detailVC, animated: true)
        } else {
            // Video selected
            let video = videos[indexPath.row]
            
            let detailVC = VideoDetailViewController()
            detailVC.videoTitle = video.title
            detailVC.videoTopic = video.topic
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// Custom cell for article entries
class ArticleCell: UITableViewCell {
    private let thumbnailView = UIView()
    private let topicLabel = UILabel()
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .white
        
        // Thumbnail
        thumbnailView.backgroundColor = UIColor(red: 175/255, green: 185/255, blue: 200/255, alpha: 1)
        thumbnailView.layer.cornerRadius = 12
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(thumbnailView)
        
        // Topic label
        topicLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        topicLabel.textColor = .black
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(topicLabel)
        
        // Title label
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .lightGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            thumbnailView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailView.widthAnchor.constraint(equalToConstant: 60),
            thumbnailView.heightAnchor.constraint(equalToConstant: 60),
            
            topicLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 12),
            topicLabel.topAnchor.constraint(equalTo: thumbnailView.topAnchor, constant: 5),
            topicLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleLabel.leadingAnchor.constraint(equalTo: topicLabel.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topicLabel.bottomAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: topicLabel.trailingAnchor)
        ])
    }
    
    func configure(topic: String, title: String) {
        topicLabel.text = topic
        titleLabel.text = title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        topicLabel.text = nil
        titleLabel.text = nil
    }
}

// Custom cell for video entries
class VideoCell: UITableViewCell {
    private let thumbnailView = UIView()
    private let playIcon = UIImageView()
    private let topicLabel = UILabel()
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .white
        
        // Thumbnail (showing a video preview appearance)
        thumbnailView.backgroundColor = UIColor(red: 175/255, green: 185/255, blue: 200/255, alpha: 1)
        thumbnailView.layer.cornerRadius = 12
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(thumbnailView)
        
        // Add a play button overlay to indicate it's a video
        playIcon.tintColor = .white
        playIcon.contentMode = .scaleAspectFit
        playIcon.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a simple play triangle
        if let playButtonImage = UIImage(systemName: "play.fill") {
            playIcon.image = playButtonImage
        }
        
        thumbnailView.addSubview(playIcon)
        
        // Topic label
        topicLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        topicLabel.textColor = .black
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(topicLabel)
        
        // Title label
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .lightGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            thumbnailView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailView.widthAnchor.constraint(equalToConstant: 60),
            thumbnailView.heightAnchor.constraint(equalToConstant: 60),
            
            playIcon.centerXAnchor.constraint(equalTo: thumbnailView.centerXAnchor),
            playIcon.centerYAnchor.constraint(equalTo: thumbnailView.centerYAnchor),
            playIcon.widthAnchor.constraint(equalToConstant: 20),
            playIcon.heightAnchor.constraint(equalToConstant: 20),
            
            topicLabel.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: 12),
            topicLabel.topAnchor.constraint(equalTo: thumbnailView.topAnchor, constant: 5),
            topicLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleLabel.leadingAnchor.constraint(equalTo: topicLabel.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topicLabel.bottomAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: topicLabel.trailingAnchor)
        ])
    }
    
    func configure(topic: String, title: String) {
        topicLabel.text = topic
        titleLabel.text = title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        topicLabel.text = nil
        titleLabel.text = nil
    }
}

// Video Detail View Controller
class VideoDetailViewController: UIViewController {
    var videoTitle: String?
    var videoTopic: String?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let videoPlayerView = UIView()
    private let playButton = UIButton()
    private let topicLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = videoTitle
        
        setupUI()
        setupConstraints()
        populateData()
    }
    
    private func setupUI() {
        // Scroll view setup
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Video player view
        videoPlayerView.backgroundColor = UIColor(red: 175/255, green: 185/255, blue: 200/255, alpha: 1)
        videoPlayerView.layer.cornerRadius = 12
        contentView.addSubview(videoPlayerView)
        
        // Play button
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tintColor = .white
        playButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        playButton.layer.cornerRadius = 25
        playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        videoPlayerView.addSubview(playButton)
        
        // Topic label
        topicLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        topicLabel.textColor = UIColor(red: 141/255, green: 212/255, blue: 109/255, alpha: 1)
        topicLabel.numberOfLines = 0
        contentView.addSubview(topicLabel)
        
        // Title label
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        
        // Description label
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Video Player
            videoPlayerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            videoPlayerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            videoPlayerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            videoPlayerView.heightAnchor.constraint(equalTo: videoPlayerView.widthAnchor, multiplier: 9/16), // 16:9 aspect ratio
            
            // Play Button
            playButton.centerXAnchor.constraint(equalTo: videoPlayerView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: videoPlayerView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Topic Label
            topicLabel.topAnchor.constraint(equalTo: videoPlayerView.bottomAnchor, constant: 20),
            topicLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            topicLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: topicLabel.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func populateData() {
        topicLabel.text = videoTopic
        titleLabel.text = videoTitle
        descriptionLabel.text = "This is a placeholder for the video description. In a real application, this would contain information about the video content, which would be fetched from a database or API. For now, we're just displaying this sample text to demonstrate the layout and functionality of the detail view controller."
    }
    
    @objc private func playVideo() {
        // In a real app, this would initiate video playback
        // For this demo, we'll just show an alert
        let alert = UIAlertController(title: "Video Playback", message: "Video playback would start here in a real application.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// Complete ArticleDetailViewController implementation
class ArticleDetailViewController: UIViewController {
    var articleTitle: String?
    var articleTopic: String?
    var articleDetails: String?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let topicLabel = UILabel()
    private let titleLabel = UILabel()
    private let detailsLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = articleTitle
        
        setupUI()
        setupConstraints()
        populateData()
    }
    
    private func setupUI() {
        // Scroll view setup
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Topic label
        topicLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        topicLabel.textColor = UIColor(red: 141/255, green: 212/255, blue: 109/255, alpha: 1)
        topicLabel.numberOfLines = 0
        contentView.addSubview(topicLabel)
        
        // Title label
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        
        // Details label
        detailsLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        detailsLabel.textColor = .darkGray
        detailsLabel.numberOfLines = 0
        contentView.addSubview(detailsLabel)
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Topic Label
            topicLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            topicLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            topicLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: topicLabel.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Details Label
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            detailsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            detailsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func populateData() {
        topicLabel.text = articleTopic
        titleLabel.text = articleTitle
        
        // Populate with default content if none provided
        if let details = articleDetails {
            detailsLabel.text = details
        } else {
            detailsLabel.text = "This is a placeholder for the article content. In a real application, this would contain the full text of the article, which would be fetched from a database or API. For now, we're just displaying this sample text to demonstrate the layout and functionality of the detail view controller."
        }
    }
}
