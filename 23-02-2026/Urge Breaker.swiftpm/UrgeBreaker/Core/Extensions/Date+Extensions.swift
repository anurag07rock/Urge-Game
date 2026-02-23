import Foundation

extension Date {
    func isSameDay(as other: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: other)
    }
    
    func isYesterday(relativeTo date: Date = Date()) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date.addingTimeInterval(-86400))
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
