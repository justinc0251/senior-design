import UIKit
import FirebaseFirestore

class LeaderboardViewController: UIViewController {

    private var scores: [(String, Int)] = []
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        fetchLeaderboardData()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchLeaderboardData() {
        let db = Firestore.firestore()
        db.collection("users")
            .order(by: "score", descending: true)
            .limit(to: 10)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                self.scores = documents.compactMap { doc in
                    let data = doc.data()
                    guard let name = data["name"] as? String, let score = data["score"] as? Int else { return nil }
                    return (name, score)
                }
                self.tableView.reloadData()
            }
    }
}

extension LeaderboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let score = scores[indexPath.row]
        cell.textLabel?.text = "\(score.0): \(score.1) points"
        return cell
    }
}
