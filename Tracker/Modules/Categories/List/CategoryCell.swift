import UIKit

final class CategoryCell: UITableViewCell {
    static let reuseId = "CategoryCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureAppearance()
    }
    
    func configure(title: String, selected: Bool) {
        let bgColor = UIColor(resource: .background)
        var background = UIBackgroundConfiguration.listGroupedCell()
        background.cornerRadius = 16
        background.backgroundColor = bgColor
        backgroundConfiguration = background
        
        backgroundColor = bgColor
        contentView.backgroundColor = bgColor
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        var content = defaultContentConfiguration()
        content.text = title
        content.textProperties.font = .systemFont(ofSize: 17)
        content.textProperties.color = UIColor(resource: .black)
        self.contentConfiguration = content
        
        accessoryType = .none
        if selected {
            let image = UIImage(resource: .icDone).withRenderingMode(.alwaysTemplate)
            let imageView = UIImageView(image: image)
            imageView.tintColor = UIColor(resource: .blue)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            accessoryView = imageView
        } else {
            accessoryView = nil
        }
        selectionStyle = .default
    }
    
    private func configureAppearance() {
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
