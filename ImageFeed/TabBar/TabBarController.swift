import UIKit

final class TabBarController: UITabBarController{
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imageListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController")
        
        let profileViewController = ProfileViewController()
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "iconProfileActive"),
            selectedImage: nil)
        
        self.viewControllers = [imageListViewController, profileViewController]
    }
}
