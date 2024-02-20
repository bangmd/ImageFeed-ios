import UIKit

class ImagesListCell: UITableViewCell {
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var viewGradient: UIView!
    static let reuseIdentifier = "ImagesListCell"
}
