import Foundation

extension Date {
    var dayOnly: Date {
        Calendar.current.startOfDay(for: self)
    }
}
