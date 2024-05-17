import UIKit
import Kingfisher
import ProgressHUD

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let showSingleImageIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private var imageListServiceObserver: NSObjectProtocol?
    private let placeholderImage = UIImage(named: "stubForPhoto")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        setUpImageListService()
        setupNotificationObserver()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        loadPhotoWithKingFisher(for: cell, indexPath: indexPath)
        createGradient(cell: cell)
        guard let date = photos[indexPath.row].createdAt else { 
            print("No date")
            return
        }
        cell.dateLabel.text = DateFormatter.dateFormatter.string(from: date)
    }
    
    private func createGradient(cell: ImagesListCell){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = cell.viewGradient.bounds
        let startColor = UIColor.clear.cgColor
        let endColor = UIColor.black.cgColor
        gradientLayer.colors = [startColor, endColor]
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        cell.viewGradient.layer.addSublayer(gradientLayer)
        cell.viewGradient.layer.cornerRadius = 16.0
        cell.viewGradient.layer.masksToBounds = true
        cell.viewGradient.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            viewController.largeImageURL = photos[indexPath.row].largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func setUpImageListService(){
        imagesListService.fetchPhotosNextPage()
        updateTableViewAnimated()
    }
    
    func setupNotificationObserver(){
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.updateTableViewAnimated()
            })
    }
    private func updateTableViewAnimated() {
        DispatchQueue.main.async {
            let oldCount = self.photos.count
            let newCount = self.imagesListService.photos.count
            self.tableView.performBatchUpdates({
                self.photos = self.imagesListService.photos
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                self.tableView.insertRows(at: indexPaths, with: .automatic)
            })
        }
    }
}


extension DateFormatter{
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}
extension ImagesListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        let thumbImageSize = photos[indexPath.row].size
        let imageInSet = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInSet.left - imageInSet.right
        let imageWidth = thumbImageSize.width
        let cellHeight = thumbImageSize.height * imageViewWidth / imageWidth + imageInSet.bottom + imageInSet.top
        return cellHeight
    }
}

extension ImagesListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell
        else {
            return UITableViewCell()
        }
        cell.delegate = self
        configCell(for: cell, with: indexPath)
        return cell
    }

    
    private func loadPhotoWithKingFisher(for cell: ImagesListCell, indexPath: IndexPath){
        let photo = photos[indexPath.row]
        
        cell.setIsLiked(photo.isLiked)
        
        if let imagesListCell = cell as? ImagesListCell {
            if let regularURL = photo.regularImageURL {
                imagesListCell.cellImage.kf.indicatorType = .activity
                imagesListCell.cellImage.kf.setImage(with: regularURL, placeholder: placeholderImage){ [weak self] _ in
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count{
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self ] result in
            guard let self else { return }
            switch result {
            case .success(let isLiked):
                self.photos[indexPath.row].isLiked = isLiked
                cell.setIsLiked(isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(_):
                UIBlockingProgressHUD.dismiss()
                DispatchQueue.main.async { [weak self] in
                    let alert = UIAlertController(title: "Error", message: "Something go wrong (", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(action)
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}
