import Foundation
import FirebaseAuth
import FirebaseFirestore

class GameHistoryManager {
    static let shared = GameHistoryManager()
    
    private init() {}
    
    func saveGameHistory(gameName: String, score: Int, completion: ((Error?) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else {
            completion?(NSError(domain: "GameHistoryManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(user.uid).updateData([
            "score": FieldValue.increment(Int64(score))
        ])
        
        db.collection("gameHistory").addDocument(data: [
            "userId": user.uid,
            "gameName": gameName,
            "score": score,
            "timestamp": Timestamp(date: Date())
        ]) { error in
            completion?(error)
        }
    }
    
    func fetchRecentGames(limit: Int = 3, completion: @escaping ([(name: String, date: Date, score: Int)]?, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "GameHistoryManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("gameHistory")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var games: [(name: String, date: Date, score: Int)] = []
                
                for document in snapshot?.documents ?? [] {
                    let data = document.data()
                    if let gameName = data["gameName"] as? String,
                       let timestamp = data["timestamp"] as? Timestamp,
                       let score = data["score"] as? Int {
                        let game = (name: gameName, date: timestamp.dateValue(), score: score)
                        games.append(game)
                    }
                }
                
                completion(games, nil)
            }
    }

    func fetchAllGames(completion: @escaping ([(name: String, date: Date, score: Int)]?, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "GameHistoryManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("gameHistory")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var games: [(name: String, date: Date, score: Int)] = []
                
                for document in snapshot?.documents ?? [] {
                    let data = document.data()
                    if let gameName = data["gameName"] as? String,
                       let timestamp = data["timestamp"] as? Timestamp,
                       let score = data["score"] as? Int {
                        let game = (name: gameName, date: timestamp.dateValue(), score: score)
                        games.append(game)
                    }
                }
                
                completion(games, nil)
            }
    }
}