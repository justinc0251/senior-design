import UIKit
import FirebaseFirestore

class LeaderboardViewController: UIViewController {

    private var scores: [(name: String, score: Int)] = []
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Leaderboard"
        setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchLeaderboardData() // Fetch data whenever the view appears
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LeaderboardCell")
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
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching leaderboard data: \(error.localizedDescription)")
                    self.showErrorAlert()
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No documents found.")
                    return
                }

                self.scores = documents.compactMap { doc in
                    let data = doc.data()
                    guard let name = data["name"] as? String, let score = data["score"] as? Int else { return nil }
                    return (name, score)
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }

    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Failed to load leaderboard data. Please try again later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension LeaderboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath)
        let score = scores[indexPath.row]
        cell.textLabel?.text = "\(indexPath.row + 1). \(score.name): \(score.score) points"
        return cell
    }
}
