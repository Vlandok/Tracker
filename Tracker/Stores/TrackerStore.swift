import UIKit
import CoreData

final class TrackerStore {
    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext { container.viewContext }
    private(set) var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    private var frcProxy: FRCProxy?
    var onChange: (() -> Void)?

    init(container: NSPersistentContainer) {
        self.container = container
    }

    func startObserving(_ onChange: @escaping () -> Void) throws {
        self.onChange = onChange
        let request = NSFetchRequest<NSManagedObject>(entityName: "TrackerCoreData")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "id", ascending: true)
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

    func makeFetchedResultsController(delegate: NSFetchedResultsControllerDelegate? = nil) throws -> NSFetchedResultsController<NSManagedObject> {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TrackerCoreData")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "id", ascending: true)
        ]
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = delegate
        try frc.performFetch()
        fetchedResultsController = frc
        return frc
    }

    func create(tracker: Tracker, categoryTitle: String?) throws {
        let trackerMO = NSEntityDescription.insertNewObject(forEntityName: "TrackerCoreData", into: context)
        trackerMO.setValue(tracker.id, forKey: "id")
        trackerMO.setValue(tracker.name, forKey: "name")
        trackerMO.setValue(tracker.emoji, forKey: "emoji")
        trackerMO.setValue(Self.hexString(from: tracker.color), forKey: "colorHex")
        trackerMO.setValue(Self.scheduleRaw(from: tracker.schedule), forKey: "scheduleRaw")

        if let title = categoryTitle {
            let catFetch = NSFetchRequest<NSManagedObject>(entityName: "TrackerCategoryCoreData")
            catFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), title)
            catFetch.fetchLimit = 1
            let category: NSManagedObject
            if let existing = try context.fetch(catFetch).first {
                category = existing
                if existing.value(forKey: "id") == nil {
                    existing.setValue(UUID(), forKey: "id")
                }
            } else {
                category = NSEntityDescription.insertNewObject(forEntityName: "TrackerCategoryCoreData", into: context)
                category.setValue(UUID(), forKey: "id")
                category.setValue(title, forKey: "title")
            }
            let set = category.mutableSetValue(forKey: "trackers")
            set.add(trackerMO)
            trackerMO.setValue(category, forKey: "category")
        }

        try context.save()
    }

    func fetchAll() throws -> [Tracker] {
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "TrackerCoreData")
        let items = try context.fetch(fetch)
        return items.compactMap { mo in
            guard
                let id = mo.value(forKey: "id") as? UUID,
                let name = mo.value(forKey: "name") as? String,
                let emoji = mo.value(forKey: "emoji") as? String,
                let colorHex = mo.value(forKey: "colorHex") as? String,
                let scheduleRaw = mo.value(forKey: "scheduleRaw") as? String
            else { return nil }
            return Tracker(
                id: id,
                name: name,
                color: Self.color(fromHex: colorHex),
                emoji: emoji,
                schedule: Self.schedule(from: scheduleRaw)
            )
        }
    }

    func fetchAllGroupedByCategory() throws -> [TrackerCategory] {
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "TrackerCoreData")
        fetch.relationshipKeyPathsForPrefetching = ["category"]
        let items = try context.fetch(fetch)
        var map: [UUID: (title: String, trackers: [Tracker])] = [:]
        for mo in items {
            guard
                let id = mo.value(forKey: "id") as? UUID,
                let name = mo.value(forKey: "name") as? String,
                let emoji = mo.value(forKey: "emoji") as? String,
                let colorHex = mo.value(forKey: "colorHex") as? String,
                let scheduleRaw = mo.value(forKey: "scheduleRaw") as? String
            else { continue }
            let tracker = Tracker(id: id,
                                  name: name,
                                  color: Self.color(fromHex: colorHex),
                                  emoji: emoji,
                                  schedule: Self.schedule(from: scheduleRaw))
            let categoryMO = mo.value(forKey: "category") as? NSManagedObject
            let catId = (categoryMO?.value(forKey: "id") as? UUID) ?? UUID()
            let title = (categoryMO?.value(forKey: "title") as? String) ?? "Без категории"
            var entry = map[catId] ?? (title: title, trackers: [])
            entry.title = title
            entry.trackers.append(tracker)
            map[catId] = entry
        }
        let categories = map.map { key, value in
            let sortedTrackers = value.trackers.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            return TrackerCategory(id: key, title: value.title, trackers: sortedTrackers)
        }
        .sorted { $0.title < $1.title }
        return categories
    }

    func delete(id: UUID) throws {
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "TrackerCoreData")
        fetch.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.id), id as CVarArg)
        if let target = try context.fetch(fetch).first {
            context.delete(target)
            try context.save()
        }
    }
}

private extension TrackerStore {
    static func hexString(from color: UIColor) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let ri = Int(round(r * 255))
        let gi = Int(round(g * 255))
        let bi = Int(round(b * 255))
        return String(format: "#%02X%02X%02X", ri, gi, bi)
    }
    static func color(fromHex hex: String) -> UIColor {
        var hexSan = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSan.hasPrefix("#") { hexSan.removeFirst() }
        guard hexSan.count == 6, let val = Int(hexSan, radix: 16) else { return .systemBlue }
        let r = CGFloat((val >> 16) & 0xFF) / 255.0
        let g = CGFloat((val >> 8) & 0xFF) / 255.0
        let b = CGFloat(val & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    static func scheduleRaw(from set: Set<Weekday>) -> String {
        let nums = set.map { $0.rawValue }.sorted()
        return nums.map { String($0) }.joined(separator: ",")
    }
    static func schedule(from raw: String) -> Set<Weekday> {
        let parts = raw.split(separator: ",").compactMap { Int($0) }
        return Set(parts.compactMap { Weekday(rawValue: $0) })
    }
}
