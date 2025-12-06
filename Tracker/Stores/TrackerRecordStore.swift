import Foundation

protocol TrackerRecordStore {
    func add(trackerId: UUID, on date: Date)
    func remove(trackerId: UUID, on date: Date)
    func contains(trackerId: UUID, on date: Date) -> Bool
    func completionCount(for trackerId: UUID) -> Int
}

final class InMemoryTrackerRecordStore: TrackerRecordStore {
    static let shared = InMemoryTrackerRecordStore()
    
    private var records: Set<TrackerRecord> = []
    private let calendar = Calendar.current
    
    private init() {}
    
    func add(trackerId: UUID, on date: Date) {
        let normalized = date.dayOnly
        let record = TrackerRecord(trackerId: trackerId, date: normalized)
        records.insert(record)
    }
    
    func remove(trackerId: UUID, on date: Date) {
        let normalized = date.dayOnly
        let record = TrackerRecord(trackerId: trackerId, date: normalized)
        records.remove(record)
    }
    
    func contains(trackerId: UUID, on date: Date) -> Bool {
        let normalized = date.dayOnly
        return records.contains(TrackerRecord(trackerId: trackerId, date: normalized))
    }
    
    func completionCount(for trackerId: UUID) -> Int {
        records.reduce(0) { $0 + ($1.trackerId == trackerId ? 1 : 0) }
    }
}


