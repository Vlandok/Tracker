import Foundation

final class CategoryListViewModel {
    let store: TrackerCategoryStore
    
    private(set) var categories: [String] = [] {
        didSet { onCategoriesChange?() }
    }
    
    var selectedCategoryTitle: String?
    var onCategoriesChange: (() -> Void)?
    var onEmptyChange: ((Bool) -> Void)?
    
    init(store: TrackerCategoryStore, selected: String?) {
        self.store = store
        self.selectedCategoryTitle = selected
    }
    
    func start() {
        reload()
        try? store.startObserving { [weak self] in
            self?.reload()
        }
    }
    
    func category(at index: Int) -> String? {
        guard index >= 0, index < categories.count else { return nil }
        return categories[index]
    }
    
    func selectCategory(at index: Int) -> String? {
        guard let title = category(at: index) else { return nil }
        selectedCategoryTitle = title
        return title
    }
    
    func refresh() {
        reload()
    }
}

private extension CategoryListViewModel {
    func reload() {
        let titles = (try? store.fetchAllTitles()) ?? []
        categories = titles.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        onEmptyChange?(categories.isEmpty)
    }
}
