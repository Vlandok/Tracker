import UIKit

final class EmojiCell: UICollectionViewCell {
    
    // MARK: - UI
    private let label = UILabel()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Configuration
    func configure(emoji: String, selected: Bool) {
        label.text = emoji
        contentView.backgroundColor = selected ? UIColor(resource: .lightGray) : .clear
    }

    // MARK: - Setup
    private func setupViews() {
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
