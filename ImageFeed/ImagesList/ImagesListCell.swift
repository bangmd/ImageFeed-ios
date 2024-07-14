import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
  func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var viewGradient: UIView!
    static let reuseIdentifier = "ImagesListCell"
    private let placeholderImage = UIImage(named: "stubForPhoto")
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellImage.kf.cancelDownloadTask()
    }

    weak var delegate: ImagesListCellDelegate?
    
    @IBAction func imageListCellDidTapLike(_ sender: UIButton) {
        delegate?.imagesListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool){
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
    }
    
}

