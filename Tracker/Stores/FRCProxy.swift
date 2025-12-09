import CoreData
import Foundation

final class FRCProxy: NSObject, NSFetchedResultsControllerDelegate {
    private let onChange: () -> Void
    init(_ onChange: @escaping () -> Void) { self.onChange = onChange }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange()
    }
}

