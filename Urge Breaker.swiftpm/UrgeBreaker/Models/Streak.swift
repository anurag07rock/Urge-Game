import Foundation

struct Streak: Codable {
    var current: Int
    var longest: Int
    var lastCompletionDate: Date?
    
    static let empty = Streak(current: 0, longest: 0, lastCompletionDate: nil)
}
