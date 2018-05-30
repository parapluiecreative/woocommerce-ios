import UIKit

class TwoColumnSectionHeaderView: UIView {
    @IBOutlet private weak var leftColumn: UILabel!
    @IBOutlet private weak var rightColumn: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    class func makeFromNib() -> TwoColumnSectionHeaderView {
        return Bundle.main.loadNibNamed("TwoColumnSectionHeaderView", owner: self, options: nil)?.first as! TwoColumnSectionHeaderView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        leftColumn.applyFootnoteStyle()
        rightColumn.applyFootnoteStyle()
        backgroundColor = .clear
    }
}

extension TwoColumnSectionHeaderView {
    func configure(leftText: String, rightText: String) {
        leftColumn.text = leftText
        rightColumn.text = rightText
    }
}
