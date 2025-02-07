import UIKit

class ArticleDetailViewController: UIViewController {

    var articleTitle: String?
    var articleDetails: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        guard let title = articleTitle, let details = articleDetails else { return }

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0

        let detailsLabel = UILabel()
        detailsLabel.text = details
        detailsLabel.font = .systemFont(ofSize: 16, weight: .regular)
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.numberOfLines = 0

        view.addSubview(titleLabel)
        view.addSubview(detailsLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            detailsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            detailsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
