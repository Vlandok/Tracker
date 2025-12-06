import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func createTrackerViewController(_ vc: CreateTrackerViewController, didCreate tracker: Tracker, in categoryTitle: String)
}

final class CreateTrackerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    weak var delegate: CreateTrackerViewControllerDelegate?
    
    private let nameLimit: Int = 38
    
    private let nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название трекера"
        field.font = .systemFont(ofSize: 17)
        field.textColor = UIColor(resource: .black)
        field.backgroundColor = UIColor(resource: .background)
        field.layer.cornerRadius = 16
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .done
        field.contentVerticalAlignment = .center
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let limitLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(resource: .red)
        label.font = .systemFont(ofSize: 17)
        label.text = "Ограничение 38 символов"
		label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
		label.setContentHuggingPriority(.required, for: .horizontal)
		label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor(resource: .red).cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(UIColor(resource: .white), for: .normal)
        button.backgroundColor = UIColor(resource: .gray)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nameStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
   

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        return table
    }()
    
    private var selectedWeekdays: Set<Weekday> = []
    private var selectedCategoryTitle: String = "Важное"
    private var tableHeaderContainer: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Новая привычка"
        
        nameField.addTarget(self, action: #selector(onNameChanged), for: .editingChanged)
        nameField.addTarget(self, action: #selector(handleReturn), for: .editingDidEndOnExit)
        cancelButton.addTarget(self, action: #selector(onCancelTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(onCreateTapped), for: .touchUpInside)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(resource: .gray)
        tableView.contentInsetAdjustmentBehavior = .never
        
        layout()
        onNameChanged()
        setupKeyboardHandling()
        setupTapToDismiss()
        configureTableHeader()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func layout() {
        view.addSubview(tableView)
        
        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(createButton)
        view.addSubview(buttonsStack)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            buttonsStack.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStack.heightAnchor.constraint(equalToConstant: 60),
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureTableHeader() {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        
        nameStack.addArrangedSubview(nameField)
        nameStack.addArrangedSubview(limitLabel)
        nameField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        container.addSubview(nameStack)
        NSLayoutConstraint.activate([
            nameStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            nameStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            nameStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            nameStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24)
        ])
		limitLabel.centerXAnchor.constraint(equalTo: nameStack.centerXAnchor).isActive = true
        
        let width = tableView.bounds.width
        let header = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        header.addSubview(container)
        container.leadingAnchor.constraint(equalTo: header.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: header.trailingAnchor).isActive = true
        container.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        
        tableView.tableHeaderView = header
        tableHeaderContainer = container
        updateTableHeaderSize()
    }
    
    private func updateTableHeaderSize() {
        guard let container = tableHeaderContainer,
              let header = tableView.tableHeaderView else { return }
        let targetSize = CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let height = container.systemLayoutSizeFitting(targetSize,
                                                       withHorizontalFittingPriority: .required,
                                                       verticalFittingPriority: .fittingSizeLevel).height
        if abs(header.frame.height - height) > 0.5 {
            var frame = header.frame
            frame.size.height = height
            header.frame = frame
            tableView.tableHeaderView = header
        }
    }
    
    @objc
    private func onNameChanged() {
        let raw = nameField.text ?? ""
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let length = trimmed.count
        let tooLong = length > nameLimit
        
        limitLabel.text = "Ограничение \(nameLimit) символов"
        limitLabel.isHidden = !tooLong
        updateTableHeaderSize()
        updateCreateButtonState()
    }
    
    private func setupTapToDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    @objc
    private func handleBackgroundTap() {
        view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIControl { return false }
        if let v = touch.view, String(describing: type(of: v)) == "UITableViewCellContentView" {
            return false
        }
        return true
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardChange(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    @objc
    private func onKeyboardChange(_ note: Notification) {
        guard
            let userInfo = note.userInfo,
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: curveRaw << 16),
                       animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCreateButtonState()
    }
    
    @objc
    private func handleReturn() {
        view.endEditing(true)
    }

    private func updateCreateButtonState() {
        let raw = nameField.text ?? ""
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameValid = (trimmed.isEmpty == false) && (trimmed.count <= nameLimit)
        let categorySelected = (selectedCategoryTitle.isEmpty == false)
        let scheduleSelected = selectedWeekdays.isEmpty == false
        let canCreate = nameValid && categorySelected && scheduleSelected
        createButton.isEnabled = canCreate
        createButton.backgroundColor = canCreate ? UIColor(resource: .black) : UIColor(resource: .gray)
    }

    private func updateCategoryAndScheduleSubtitles() {
        updateCreateButtonState()
    }
    
    @objc
    private func onCategoryTapped() {}
    
    @objc
    private func onScheduleTapped() {
        let vc = SchedulePickerViewController(initial: selectedWeekdays) { [weak self] newSet in
            self?.selectedWeekdays = newSet
            self?.updateCategoryAndScheduleSubtitles()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func onCancelTapped() {
        dismiss(animated: true)
    }
    
    @objc
    private func onCreateTapped() {
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard name.isEmpty == false else { return }
        
        let emojis = ["🙂","😀","😅","🥳","🤩","😎","🥰","😺","🍀","🌟","🔥","❤️","🎯","🏃‍♂️","🧘‍♂️","📚","🎵","🚴‍♂️","🌤️","🌙"]
        let colors: [UIColor] = [
            .systemGreen, .systemOrange, .systemRed, .systemBlue,
            .systemPurple, .systemTeal, .systemPink, .systemIndigo
        ]
        let chosenEmoji = emojis.randomElement() ?? "🙂"
        let chosenColor = colors.randomElement() ?? UIColor.systemBlue
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: chosenColor,
            emoji: chosenEmoji,
            schedule: selectedWeekdays
        )
        let categoryTitle = selectedCategoryTitle
        delegate?.createTrackerViewController(self, didCreate: tracker, in: categoryTitle)
        dismiss(animated: true)
    }
}

extension CreateTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { CGFloat.leastNormalMagnitude }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { CGFloat.leastNormalMagnitude }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        cell.backgroundColor = .clear
        var bg = UIBackgroundConfiguration.listGroupedCell()
        bg.backgroundColor = .secondarySystemBackground
        bg.cornerRadius = 16
        cell.backgroundConfiguration = bg
        var content = cell.defaultContentConfiguration()
        content.textProperties.font = .systemFont(ofSize: 17)
        content.textProperties.color = UIColor(resource: .black)
        content.secondaryTextProperties.color = UIColor(resource: .gray)
        content.secondaryTextProperties.font = .systemFont(ofSize: 17)
        if indexPath.row == 0 {
            content.text = "Категория"
            content.secondaryText = selectedCategoryTitle
        } else {
            content.text = "Расписание"
            content.secondaryText = scheduleSummary(from: selectedWeekdays)
        }
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            return
        } else {
            let vc = SchedulePickerViewController(initial: selectedWeekdays) { [weak self] newSet in
                self?.selectedWeekdays = newSet
                self?.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func scheduleSummary(from set: Set<Weekday>) -> String {
        guard set.isEmpty == false else { return "" }
        if set.count == Weekday.allCases.count {
            return "Каждый день"
        }
        let order: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        let map: [Weekday: String] = [
            .monday: "Пн", .tuesday: "Вт", .wednesday: "Ср", .thursday: "Чт",
            .friday: "Пт", .saturday: "Сб", .sunday: "Вс"
        ]
        return order.filter { set.contains($0) }.compactMap { map[$0] }.joined(separator: ", ")
    }
}


