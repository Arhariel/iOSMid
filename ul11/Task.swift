import Foundation
import FirebaseFirestore

struct Task: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var category: String
    var note: String?
}
