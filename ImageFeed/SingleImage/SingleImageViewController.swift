import UIKit
import ProgressHUD
import Kingfisher

final class SingleImageViewController: UIViewController{
    var image: UIImage? {
        didSet{
            guard isViewLoaded else { return }
            imageView.image = self.image
            guard let image else { return }
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    var largeImageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPhoto()
    }
    
    func loadPhoto(){
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: largeImageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                self.imageView.image = imageResult.image
                self.imageView.frame.size = imageResult.image.size
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                showError()
            }
        }
    }
    
    func showError(){
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let alert = UIAlertController(title: "Error", message: "Something go wrong", preferredStyle: .alert)
            let action = UIAlertAction(title: "Reload", style: .default){_ in 
                self.loadPhoto()
            }
            alert.addAction(action)
            present(alert, animated: true)
        }
    }
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let shareViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(shareViewController, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.minimumZoomScale = scale
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
