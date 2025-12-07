import UIKit

final class InsetClearTextField: UITextField {
    var clearSize: CGFloat = 17
    var rightPadding: CGFloat = 12
    var gap: CGFloat = 12
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let y = bounds.midY - clearSize / 2
        let x = bounds.maxX - rightPadding - clearSize
        return CGRect(x: x, y: y, width: clearSize, height: clearSize)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        insetRect(forBounds: bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        insetRect(forBounds: bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        insetRect(forBounds: bounds)
    }
    
    private func insetRect(forBounds bounds: CGRect) -> CGRect {
        let rightInset = rightPadding + clearSize + gap
        let leftInset = (leftView?.frame.width ?? 0)
        return bounds.inset(by: UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset))
    }
}
