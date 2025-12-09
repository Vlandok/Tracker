import CoreData

@objc(TrackerCategoryCoreData)
final class TrackerCategoryCoreData: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var title: String?
    @NSManaged var trackers: NSSet?
}

@objc(TrackerCoreData)
final class TrackerCoreData: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var emoji: String?
    @NSManaged var colorHex: String?
    @NSManaged var scheduleRaw: String?
    @NSManaged var category: TrackerCategoryCoreData?
    @NSManaged var records: NSSet?
}

@objc(TrackerRecordCoreData)
final class TrackerRecordCoreData: NSManagedObject {
    @NSManaged var date: Date?
    @NSManaged var tracker: TrackerCoreData?
}
