import UIKit
class GalleryViewController: UIViewController {
    fileprivate var animationController = JKPhotoTransition()
    var hideSelectedCell = false
    @IBOutlet weak var collectionView: UICollectionView!
    var photoArray: [Photo]  {
        var PhArray = [Photo]()
        for x in 1...7 {
            let image = UIImage(named:"\(x)")
            let title = "Photo \(x)"
            let this = Photo(title: title, image: image!)
            PhArray.append(this)
        }
        return PhArray
    }
    var selectedIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photos"
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
}
// MARK: CollectioViewSetup
extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width/2 - 4
        return CGSize(width: width , height: width )
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        let photo = photoArray[indexPath.row]
        cell.imageView.image = (indexPath.row == selectedIndex && hideSelectedCell) ? nil : photo.image
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.transitioningDelegate = self
        vc.galleryDelegate = self
        vc.currentImage = photoArray[selectedIndex!].image
        vc.navTitle = photoArray[selectedIndex!].title
        present(vc, animated: true, completion: nil)
    }
}
// MARK: UIViewControllerTransitioningDelegate
// 1: Conforming to protocol
extension GalleryViewController: UIViewControllerTransitioningDelegate {

    // 2: presentation controller
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.setupImageTransition( image: photoArray[selectedIndex!].image,
                                                  fromDelegate: self,
                                                  toDelegate: presented as! DetailViewController)
        return animationController
    }

    // 3: dismissing controller
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.setupImageTransition( image: photoArray[selectedIndex!].image,
                                                  fromDelegate: dismissed as! DetailViewController,
                                                  toDelegate: self)
        return animationController
    }
}
// MARK: ImageTransitionProtocol
extension GalleryViewController: ImageTransitionProtocol {
    // 1: hide selected cell for tranisition snapshot
    func tranisitionSetup(){
        hideSelectedCell = true
        collectionView.reloadData()
    }

    // 2: unhide selected cell after tranisition snapshot is taken
    func tranisitionCleanup(){
        hideSelectedCell = false
        collectionView.reloadData()
    }
    // 3: return window frame of selected image
    func imageWindowFrame() -> CGRect{
        let indexPath = IndexPath(row: selectedIndex!, section: 0)
        let attributes = collectionView.layoutAttributesForItem(at: indexPath)
        let cellRect = attributes!.frame
        return collectionView.convert(cellRect, to: self.view)
    }
}
// MARK: UIViewControllerTransitioningDelegate
extension GalleryViewController: GalleryDelegate {
    func updateSelectedIndex(_ newIndex: Int){
        selectedIndex = newIndex
    }
}
protocol GalleryDelegate {
    func updateSelectedIndex(_ newIndex: Int)
}
