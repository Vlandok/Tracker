import UIKit

final class ColorCell: UICollectionViewCell {
    private let swatchView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 8
        contentView.layer.borderColor = UIColor(resource: .gray).cgColor
        contentView.layer.borderWidth = 0
        
        swatchView.translatesAutoresizingMaskIntoConstraints = false
        swatchView.layer.cornerRadius = 8
        contentView.addSubview(swatchView)
        NSLayoutConstraint.activate([
            swatchView.widthAnchor.constraint(equalToConstant: 40),
            swatchView.heightAnchor.constraint(equalToConstant: 40),
            swatchView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            swatchView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(color: UIColor, selected: Bool) {
        swatchView.backgroundColor = color
        contentView.layer.borderWidth = selected ? 3 : 0
        contentView.layer.borderColor = selected ? color.cgColor : UIColor.clear.cgColor
    }
}
