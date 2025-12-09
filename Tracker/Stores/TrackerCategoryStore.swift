import Foundation
import CoreData

final class TrackerCategoryStore {
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
        let request = NSFetchRequest<NSManagedObject>(entityName: "TrackerCategoryCoreData")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
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

    func findOrCreate(title: String) throws -> NSManagedObject {
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "TrackerCategoryCoreData")
        fetch.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), title)
        fetch.fetchLimit = 1
        if let existing = try context.fetch(fetch).first {
            return existing
        }
        let entity = NSEntityDescription.insertNewObject(forEntityName: "TrackerCategoryCoreData", into: context)
        entity.setValue(title, forKey: "title")
        try context.save()
        return entity
    }

    func fetchAllTitles() throws -> [String] {
        let fetch = NSFetchRequest<NSDictionary>(entityName: "TrackerCategoryCoreData")
        fetch.propertiesToFetch = ["title"]
        fetch.resultType = .dictionaryResultType
        let items = try context.fetch(fetch)
        return items.compactMap { $0["title"] as? String }
    }
}
