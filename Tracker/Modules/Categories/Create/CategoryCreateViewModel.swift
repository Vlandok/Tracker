import Foundation

final class CategoryCreateViewModel {
    let nameLimit: Int = 38
    
    private let store: TrackerCategoryStore
    
    var onValidityChange: ((Bool) -> Void)?
    var onSaved: (() -> Void)?
    
    init(store: TrackerCategoryStore) {
        self.store = store
    }
    
    func validate(name: String?) {
        let trimmed = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let isValid = trimmed.isEmpty == false && trimmed.count <= nameLimit
        onValidityChange?(isValid)
    }
    
    func save(name: String?) {
        let trimmed = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false, trimmed.count <= nameLimit else { return }
        try? store.findOrCreate(title: trimmed)
        onSaved?()
    }
}
