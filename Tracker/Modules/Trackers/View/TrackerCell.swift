import UIKit

final class TrackerCell: UICollectionViewCell {
    static let reuseId = "TrackerCell"
    
    var onToggle: (() -> Void)?
    
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(resource: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .systemBlue.withAlphaComponent(0.15)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(cardView)
        contentView.addSubview(daysLabel)
        contentView.addSubview(toggleButton)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)
        
        toggleButton.addTarget(self, action: #selector(onToggleTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.centerYAnchor.constraint(equalTo: toggleButton.centerYAnchor),
            
            toggleButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            toggleButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            toggleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            toggleButton.widthAnchor.constraint(equalToConstant: 34),
            toggleButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, totalCount: Int, isFutureDate: Bool) {
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        
        daysLabel.text = Self.daysText(totalCount)
        
        let imageName = isCompleted ? "checkmark" : "plus"
        let configuration = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let image = UIImage(systemName: imageName, withConfiguration: configuration)
        toggleButton.setImage(image, for: .normal)
        toggleButton.backgroundColor = isCompleted ? tracker.color.withAlphaComponent(0.2) : tracker.color
        
        toggleButton.isEnabled = !isFutureDate
        toggleButton.alpha = isFutureDate ? 0.5 : 1.0
    }
    
    @objc
    private func onToggleTapped() {
        onToggle?()
    }
    
    private static func daysText(_ count: Int) -> String {
        let mod10 = count % 10
        let mod100 = count % 100
        let suffix: String
        if mod10 == 1 && mod100 != 11 {
            suffix = "день"
        } else if (2...4).contains(mod10) && !(12...14).contains(mod100) {
            suffix = "дня"
        } else {
            suffix = "дней"
        }
        return "\(count) \(suffix)"
    }
}

final class TrackerSectionHeaderView: UICollectionReusableView {
    static let reuseId = "TrackerSectionHeaderView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(resource: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
