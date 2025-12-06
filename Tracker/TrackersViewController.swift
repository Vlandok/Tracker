import UIKit

final class TrackersViewController: UIViewController {
    
    private var selectedDate: Date = Date()
    
    var categories: [TrackerCategory] = [TrackerCategory(title: "Важное", trackers: [])]
    private let recordStore: TrackerRecordStore = InMemoryTrackerRecordStore.shared
    private var visible: [TrackerCategory] = []
    
    private lazy var addButton: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddTapped))
        item.tintColor = UIColor(resource: .black)
        return item
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.date = selectedDate
        picker.addTarget(self, action: #selector(onDateChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: Self.makeLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset.top = 8
        collectionView.contentInset.bottom = 0
        collectionView.scrollIndicatorInsets.bottom = 0
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseId)
        collectionView.register(TrackerSectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerSectionHeaderView.reuseId)
        return collectionView
    }()
    
    private let emptyImageView: UIImageView = {
        let image = UIImage(resource: .emptyState)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .tertiaryLabel
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = UIColor(resource: .black)
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emptyImageView, emptyLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Поиск"
        controller.searchBar.searchTextField.clearButtonMode = .always
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Трекеры"
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchController
        definesPresentationContext = true
        layoutCollection()
        layoutEmptyState()
        updateUIForSelectedDate()
    }
    
    private func layoutEmptyState() {
        view.addSubview(emptyStack)
        
        NSLayoutConstraint.activate([
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStack.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func layoutCollection() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc
    private func onAddTapped() {
        let createVC = CreateTrackerViewController()
        createVC.delegate = self
        let nav = UINavigationController(rootViewController: createVC)
        present(nav, animated: true)
    }
    
    @objc
    private func onDateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        updateUIForSelectedDate()
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
            let existing = categories[index]
            let updatedCategory = TrackerCategory(title: existing.title, trackers: existing.trackers + [tracker])
            var newCategories = categories
            newCategories[index] = updatedCategory
            categories = newCategories
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            categories = categories + [newCategory]
        }
        updateUIForSelectedDate()
    }
    
    func markCompleted(tracker: Tracker, on date: Date) {
        recordStore.add(trackerId: tracker.id, on: date)
    }
    
    func unmarkCompleted(tracker: Tracker, on date: Date) {
        recordStore.remove(trackerId: tracker.id, on: date)
    }
    
    private func updateUIForSelectedDate() {
        visible = visibleCategories(for: selectedDate)
        emptyStack.isHidden = visible.flatMap { $0.trackers }.isEmpty == false
        collectionView.reloadData()
    }
    
    private func visibleCategories(for date: Date) -> [TrackerCategory] {
        let weekday = weekday(for: date)
        let filtered: [TrackerCategory] = categories.compactMap { category in
            let trackersForDay = category.trackers.filter { tracker in
                tracker.schedule.isEmpty || tracker.schedule.contains(weekday)
            }
            guard trackersForDay.isEmpty == false else { return nil }
            return TrackerCategory(title: category.title, trackers: trackersForDay)
        }
        return filtered
    }
    
    private func weekday(for date: Date) -> Weekday {
        let value = Calendar.current.component(.weekday, from: date)
        switch value {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        default: return .saturday
        }
    }
    
    private static func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(148)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(132)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(18))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension TrackersViewController: CreateTrackerViewControllerDelegate {
    func createTrackerViewController(_ vc: CreateTrackerViewController, didCreate tracker: Tracker, in categoryTitle: String) {
        addTracker(tracker, to: categoryTitle)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visible.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visible[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseId, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let tracker = visible[indexPath.section].trackers[indexPath.item]
        let completed = isCompleted(tracker: tracker, on: selectedDate)
        let totalCount = completionCount(for: tracker)
        let isFuture = isFutureSelectedDate()
        cell.configure(with: tracker, isCompleted: completed, totalCount: totalCount, isFutureDate: isFuture)
        cell.onToggle = { [weak self] in
            self?.toggleCompletion(for: tracker)
            self?.collectionView.reloadItems(at: [indexPath])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: TrackerSectionHeaderView.reuseId,
                                                                     for: indexPath) as! TrackerSectionHeaderView
        header.setTitle(visible[indexPath.section].title)
        return header
    }
}

extension TrackersViewController: UICollectionViewDelegate {}

private extension TrackersViewController {
    func isCompleted(tracker: Tracker, on date: Date) -> Bool {
        recordStore.contains(trackerId: tracker.id, on: date)
    }
    
    func completionCount(for tracker: Tracker) -> Int {
        recordStore.completionCount(for: tracker.id)
    }
    
    func isFutureSelectedDate() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let sel = Calendar.current.startOfDay(for: selectedDate)
        return sel > today
    }
    
    func toggleCompletion(for tracker: Tracker) {
        guard isFutureSelectedDate() == false else { return }
        if isCompleted(tracker: tracker, on: selectedDate) {
            unmarkCompleted(tracker: tracker, on: selectedDate)
        } else {
            markCompleted(tracker: tracker, on: selectedDate)
        }
    }
}

