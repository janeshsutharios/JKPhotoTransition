import UIKit
class PhotoViewController: UIViewController, UIScrollViewDelegate {
    
    // view outlets
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentWidthConstraint: NSLayoutConstraint!
    
    // data
    var allPhotoScrollViews: Array<UIScrollView> = []
    var allPhotos: Array<Photo> = []
    var currentPhotoIndex: Int = 0
    
    // delegate
    var galleryDelegate: GalleryDelegate?
    var statusBarHidden: Bool = false
    var scrollViewDragging: Bool = false
    
    // MARK: Public Setup Methods
    
    func setupWithPhotos(photos: [Photo], selectedPhotoIndex: Int){
        allPhotos = photos
        currentPhotoIndex = selectedPhotoIndex
    }

    // MARK: Setup methods
    
    // adds styling and image views
    override func viewDidLoad() {

        updateTitle()
        scrollView.delegate = self
        
        // add colours
        view.backgroundColor = UIColor.blackColor()
        titleLabel.textColor = UIColor.whiteColor()
        colourButton(exitButton)
        colourButton(moreButton)
        
        // add shadows
        addShadowToView(exitButton)
        addShadowToView(moreButton)
        addShadowToView(titleLabel)
        
        // add image views
        setupImageViews()
    }
    
    private func setupImageViews(){

        // create all image views
        var previousView: UIView = contentView
        for x in 0...allPhotos.count-1 {
            
            let photo = allPhotos[x]
            
            // create sub scrollview
            let subScrollView = UIScrollView()
            subScrollView.delegate = self
            contentView.addSubview(subScrollView)
            allPhotoScrollViews.append(subScrollView)
            
            // create imageview
            let imageView = UIImageView(image: photo.image)
            imageView.contentMode = .ScaleAspectFill
            subScrollView.addSubview(imageView)
            
            // add subScrollView constraints
            subScrollView.translatesAutoresizingMaskIntoConstraints = false
            let attribute: NSLayoutAttribute = (x == 0) ? .Leading : .Trailing
            scrollView.addConstraint(NSLayoutConstraint(item: subScrollView, attribute: .Leading, relatedBy: .Equal, toItem: previousView, attribute: attribute, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: subScrollView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: subScrollView, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: subScrollView, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: 1, constant: 0))
            
            // add imageview constraints
            imageView.translatesAutoresizingMaskIntoConstraints = false
            subScrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Height, multiplier: (photo.image.size.width / photo.image.size.height), constant: 0))
            subScrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: subScrollView, attribute: .CenterX, multiplier: 1, constant: 0))
            subScrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: subScrollView, attribute: .CenterY, multiplier: 1, constant: 0))

            // add imageview side constraints
            for attribute: NSLayoutAttribute in [.Top, .Bottom, .Leading, .Trailing] {
                let constraintLowPriority = NSLayoutConstraint(item: imageView, attribute: attribute, relatedBy: .Equal, toItem: subScrollView, attribute: attribute, multiplier: 1, constant: 0)
                let constraintGreaterThan = NSLayoutConstraint(item: imageView, attribute: attribute, relatedBy: .GreaterThanOrEqual, toItem: subScrollView, attribute: attribute, multiplier: 1, constant: 0)
                constraintLowPriority.priority = 750
                subScrollView.addConstraints([constraintLowPriority,constraintGreaterThan])
            }
            
            // set as previous
            previousView = subScrollView
        }
        let xOffset = CGFloat(currentPhotoIndex) * scrollView.frame.size.width
        scrollView.contentOffset = CGPointMake(xOffset, 0)
    }
    
    // ensure scroll view has correct content size when the view size changes
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentWidthConstraint.constant = CGFloat(allPhotos.count) * scrollView.frame.size.width
        if !scrollViewDragging {
            scrollView.contentOffset = CGPointMake(CGFloat(currentPhotoIndex) * scrollView.frame.size.width, 0)
        }
    }

    // MARK: Styling Methods
    
    private func colourButton(button: UIButton){
        let tintableImage = button.backgroundImageForState(.Normal)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        button.setBackgroundImage(tintableImage, forState: .Normal)
        button.tintColor = UIColor.whiteColor()
    }
    
    private func addShadowToView(view: UIView){
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = CGSizeMake(2.0, 2.0)
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            scrollViewDragging = true
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            scrollViewDragging = false
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.scrollView && scrollViewDragging {
            currentPhotoIndex = getCurrentPageIndex()
            updateTitle()
        }
    }
    
    // MARK: Utility Methods
    
    private func getCurrentPageIndex() -> Int {
        return Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
    }
    
    private func updateTitle(){
        titleLabel.text = allPhotos[currentPhotoIndex].title
    }

    // MARK: Button Actions
    
    @IBAction func moreButtonSelected() {
        // do something
    }
    
    @IBAction func backButtonSelected() {
        galleryDelegate?.updateSelectedIndex(currentPhotoIndex)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Status Bar
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        statusBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        statusBarHidden = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
}

// MARK: ImageTransitionProtocol

extension PhotoViewController: ImageTransitionProtocol {
    
    // 1: hide scroll view containing images
    func tranisitionSetup(){
        let photo = allPhotos[currentPhotoIndex]
        titleLabel.text = photo.title
        scrollView.hidden = true
    }
    
    // 2; unhide images and set correct image to be showing
    func tranisitionCleanup(){
        scrollView.hidden = false
        let xOffset = CGFloat(currentPhotoIndex) * scrollView.frame.size.width
        scrollView.contentOffset = CGPointMake(xOffset, 0)
    }
    
    // 3: return the imageView window frame
    func imageWindowFrame() -> CGRect{

        let photo = allPhotos[currentPhotoIndex]
        let scrollWindowFrame = scrollView.superview!.convertRect(scrollView.frame, toView: nil)
        
        let scrollViewRatio = scrollView.frame.size.width / scrollView.frame.size.height
        let imageRatio = photo.image.size.width / photo.image.size.height
        let touchesSides = (imageRatio > scrollViewRatio)
        
        if touchesSides {
            let height = scrollWindowFrame.size.width / imageRatio
            let yPoint = scrollWindowFrame.origin.y + (scrollWindowFrame.size.height - height) / 2
            return CGRectMake(scrollWindowFrame.origin.x, yPoint, scrollWindowFrame.size.width, height)
        } else {
            let width = scrollWindowFrame.size.height * imageRatio
            let xPoint = scrollWindowFrame.origin.x + (scrollWindowFrame.size.width - width) / 2
            return CGRectMake(xPoint, scrollWindowFrame.origin.y, width, scrollWindowFrame.size.height)
        }
    }
}
