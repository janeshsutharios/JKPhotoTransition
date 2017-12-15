import UIKit
import AVFoundation
class DetailViewController: UIViewController {
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var DetailDataImageView: UIImageView!

    var currentImage: UIImage?
    var navTitle  = ""
    var galleryDelegate: GalleryDelegate?

    override func viewDidLoad() {
        DetailDataImageView.image = nil
    }
    @IBAction func backButtonSelected() {
        dismiss(animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        DetailDataImageView.image = nil
    }
}
// MARK: ImageTransitionProtocol
extension DetailViewController: ImageTransitionProtocol {
    func tranisitionSetup(){
        titleLabel.text = navTitle
    }
    func tranisitionCleanup(){// 2: unhide images and set correct image to be showing
        DetailDataImageView.image = currentImage
    }
    func imageWindowFrame() -> CGRect{// 3: return the imageView window frame
        return  AVMakeRect(aspectRatio: (currentImage?.size)!, insideRect: DetailDataImageView.frame)
    }
}
