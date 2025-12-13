import UIKit

final class CategoryCreateViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    private let viewModel: CategoryCreateViewModel
    
    private let nameField: UITextField = {
        let field = InsetClearTextField()
        field.placeholder = "Введите название категории"
        field.font = .systemFont(ofSize: 17)
        field.textColor = UIColor(resource: .black)
        field.backgroundColor = UIColor(resource: .background)
        field.layer.cornerRadius = 16
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.clearButtonMode = .whileEditing
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let limitLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(resource: .red)
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
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
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(UIColor(resource: .white), for: .normal)
        button.backgroundColor = UIColor(resource: .gray)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    init(viewModel: CategoryCreateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Новая категория"
        navigationItem.hidesBackButton = true
        
        nameField.delegate = self
        nameField.addTarget(self, action: #selector(onNameChanged), for: .editingChanged)
        doneButton.addTarget(self, action: #selector(onDoneTapped), for: .touchUpInside)
        setupTapToDismiss()
        
        nameStack.addArrangedSubview(nameField)
        nameStack.addArrangedSubview(limitLabel)
        nameField.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        view.addSubview(nameStack)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            nameStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.onValidityChange = { [weak self] isValid in
            self?.doneButton.isEnabled = isValid
            self?.doneButton.backgroundColor = isValid ? UIColor(resource: .black) : UIColor(resource: .gray)
        }
        viewModel.onSaved = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc
    private func onNameChanged() {
        let trimmed = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let tooLong = trimmed.count > viewModel.nameLimit
        limitLabel.text = "Ограничение \(viewModel.nameLimit) символов"
        limitLabel.isHidden = !tooLong
        viewModel.validate(name: nameField.text)
    }
    
    @objc
    private func onDoneTapped() {
        viewModel.save(name: nameField.text)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
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
}
