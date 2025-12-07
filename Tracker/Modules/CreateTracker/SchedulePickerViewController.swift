import UIKit

final class SchedulePickerViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private var selected: Set<Weekday>
    private let onDone: (Set<Weekday>) -> Void
    private var tableHeightConstraint: NSLayoutConstraint?
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(UIColor(resource: .white), for: .normal)
        button.backgroundColor = UIColor(resource: .black)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(initial: Set<Weekday>, onDone: @escaping (Set<Weekday>) -> Void) {
        self.selected = initial
        self.onDone = onDone
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .white)
        navigationItem.title = "Расписание"
        navigationItem.hidesBackButton = true
        
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(resource: .gray)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableHeaderView = nil
        
        view.addSubview(tableView)
        view.addSubview(doneButton)
        doneButton.addTarget(self, action: #selector(onDoneTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
        
        view.layoutIfNeeded()
        tableHeightConstraint?.constant = tableView.contentSize.height
        tableHeightConstraint?.isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = tableView.contentSize.height
        if abs((tableHeightConstraint?.constant ?? 0) - height) > 0.5 {
            tableHeightConstraint?.constant = height
        }
    }
    
    @objc
    private func onDoneTapped() {
        onDone(selected)
        navigationController?.popViewController(animated: true)
    }
}

extension SchedulePickerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Weekday.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 24 }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let weekday = Weekday.allCases[indexPath.row]
        cell.selectionStyle = .none
        cell.textLabel?.text = localizedName(for: weekday)
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = UIColor(resource: .black)
        var bg = UIBackgroundConfiguration.listGroupedCell()
        bg.backgroundColor = .secondarySystemBackground
        cell.backgroundConfiguration = bg
        
        let toggle = UISwitch()
        toggle.onTintColor = UIColor(resource: .blue)
        toggle.isOn = selected.contains(weekday)
        toggle.tag = indexPath.row
        toggle.addTarget(self, action: #selector(onToggleChanged(_:)), for: .valueChanged)
        cell.accessoryView = toggle
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {}
    
    @objc
    private func onToggleChanged(_ sender: UISwitch) {
        let weekday = Weekday.allCases[sender.tag]
        if sender.isOn {
            selected.insert(weekday)
        } else {
            selected.remove(weekday)
        }
    }
    
    private func localizedName(for weekday: Weekday) -> String {
        switch weekday {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
}
