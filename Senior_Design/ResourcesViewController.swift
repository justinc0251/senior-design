import UIKit

class ResourcesViewController: UIViewController {

    private let tableView = UITableView()
    private let articles: [(title: String, description: String, details: String)] = [
        ("The Importance of Recycling",
         "Learn why recycling is crucial for waste management and how it impacts the environment.",
         "Recycling reduces the need for extracting, refining, and processing raw materials, all of which create substantial air and water pollution."),
        ("Composting 101",
         "A beginner's guide to composting and turning organic waste into nutrient-rich soil.",
         "Composting involves the decomposition of organic matter, such as leaves, vegetable scraps, and coffee grounds, into nutrient-rich soil."),
        ("Reducing Plastic Waste",
         "Explore strategies to minimize plastic use and promote sustainable alternatives.",
         "Reducing plastic waste involves adopting reusable alternatives, participating in cleanups, and supporting policies to limit single-use plastics."),
        ("E-Waste Management",
         "Discover safe disposal methods for electronic waste to prevent environmental harm.",
         "E-waste can be recycled to recover valuable metals like gold and copper, reducing the need for mining and conserving resources."),
        ("Community Cleanup Programs",
         "Find out how to organize or participate in local cleanup initiatives.",
         "Community cleanup programs bring people together to remove litter and beautify public spaces, fostering a sense of community and environmental responsibility.")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Resources"
        view.backgroundColor = .white
        setupTableView()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ArticleCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ResourcesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
        let article = articles[indexPath.row]
        cell.textLabel?.text = article.title
        cell.textLabel?.numberOfLines = 0
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articles[indexPath.row]

        let detailVC = ArticleDetailViewController()
        detailVC.articleTitle = article.title
        detailVC.articleDetails = article.details
        navigationController?.pushViewController(detailVC, animated: true)
    }

}
