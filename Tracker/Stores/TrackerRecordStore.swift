import Foundation
import CoreData

final class TrackerRecordStore {
    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext { container.viewContext }
    private let calendar = Calendar.current
    private(set) var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    private var frcProxy: FRCProxy?
    var onChange: (() -> Void)?

    init(container: NSPersistentContainer) {
        self.container = container
    }

    func startObservingForDay(_ date: Date, _ onChange: @escaping () -> Void) throws {
        self.onChange = onChange
        let start = calendar.startOfDay(for: date) as NSDate
        let request = NSFetchRequest<NSManagedObject>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.date), start)
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        let proxy = FRCProxy { [weak self] in self?.onChange?() }
        frc.delegate = proxy
        try frc.performFetch()
        fetchedResultsController = frc
        frcProxy = proxy
    }

    func startObservingForTracker(_ trackerId: UUID, _ onChange: @escaping () -> Void) throws {
        self.onChange = onChange
        let request = NSFetchRequest<NSManagedObject>(entityName: "TrackerRecordCoreData")
        if let trackerMO = try fetchTrackerMO(by: trackerId) {
            request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.tracker), trackerMO)
        } else {
            request.predicate = NSPredicate(value: false)
        }
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        let proxy = FRCProxy { [weak self] in self?.onChange?() }
        frc.delegate = proxy
        try frc.performFetch()
        fetchedResultsController = frc
        frcProxy = proxy
    }

    func add(trackerId: UUID, on date: Date) throws {
        guard let trackerMO = try fetchTrackerMO(by: trackerId) else { return }
        let record = NSEntityDescription.insertNewObject(forEntityName: "TrackerRecordCoreData", into: context)
        record.setValue(calendar.startOfDay(for: date), forKey: "date")
        record.setValue(trackerMO, forKey: "tracker")
        try context.save()
    }

    func remove(trackerId: UUID, on date: Date) throws {
        let day = calendar.startOfDay(for: date) as NSDate
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "TrackerRecordCoreData")
        fetch.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.date), day)
        let items = try context.fetch(fetch)
        if let trackerMO = try fetchTrackerMO(by: trackerId) {
            for mo in items {
                if let t = mo.value(forKey: "tracker") as? NSManagedObject, t.objectID == trackerMO.objectID {
                    context.delete(mo)
                }
            }
        }
        if context.hasChanges { try context.save() }
    }

    func isCompleted(trackerId: UUID, on date: Date) throws -> Bool {
        guard let trackerMO = try fetchTrackerMO(by: trackerId) else { return false }
        let day = calendar.startOfDay(for: date) as NSDate
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "TrackerRecordCoreData")
        fetch.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.date), day)
        let items = try context.fetch(fetch)
        return items.contains { mo in
            if let t = mo.value(forKey: "tracker") as? NSManagedObject {
                return t.objectID == trackerMO.objectID
            }
            return false
        }
    }

    func completionCount(for trackerId: UUID) throws -> Int {
        guard let trackerMO = try fetchTrackerMO(by: trackerId) else { return 0 }
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "TrackerRecordCoreData")
        let items = try context.fetch(fetch)
        let count = items.reduce(into: 0) { partial, mo in
            if let t = mo.value(forKey: "tracker") as? NSManagedObject, t.objectID == trackerMO.objectID {
                partial += 1
            }
        }
        return count
    }

    private func fetchTrackerMO(by id: UUID) throws -> NSManagedObject? {
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "TrackerCoreData")
        fetch.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.id), id as CVarArg)
        fetch.fetchLimit = 1
        return try context.fetch(fetch).first
    }
}

