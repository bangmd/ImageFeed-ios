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
    func loadCell(from photo: Photo) -> Bool {
          var status = false

//          if let photoDate = photo.createdAt {
//              dataLabel.text = dateFormatter.string(from: photoDate)
//          } else {
//              dataLabel.text = ""
//          }
//            
//            setIsLiked(photo.isLiked)

          guard let photoURL = URL(string: photo.thumbImageURL) else { return status }

            cellImage.kf.indicatorType = .activity
            cellImage.kf.setImage(with: photoURL, placeholder: placeholderImage) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
              status = true
            case .failure(let error):
                cellImage.image = placeholderImage
                debugPrint("Error: \(error.localizedDescription)")
            }
          }
          return status
        }
    
}

