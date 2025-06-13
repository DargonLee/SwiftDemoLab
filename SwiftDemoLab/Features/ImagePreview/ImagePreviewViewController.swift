//
//  ImagePreviewViewController.swift
//  SLFoundation
//
//  Created by fenglianyi on 2024/6/21.
//

import UIKit
import SLDataModel

public class ImagePreviewViewController: UIViewController {
    public struct InputContext {
        public var transitionImage: UIImage
        public var imageList: [ImageItem] = []
        public var preViewIndex: Int = 0
        public var showDelete: Bool = true
        
        public init(transitionImage: UIImage, imageList: [ImageItem], preViewIndex: Int, showDelete: Bool) {
            self.transitionImage = transitionImage
            self.imageList = imageList
            self.preViewIndex = preViewIndex
            self.showDelete = showDelete
        }
    }
    
    // action handler
    // 删除Item
    public var deleteHandle: ((ImageItem) -> Void)?
    // 删除后图片列表，不改动不触发
    public var finallyImageListHandle: (([ImageItem]) -> Void)?
    
    // init
    var inputContext: InputContext
    weak var delegate: ImagePreviewViewControllerDelegate?
    var frameOfIndexProvider: ((Int, ImageItem?) -> CGRect)
    
    var imageList: [ImageItem] = []
    var preViewIndex: Int = 0
    var hasEdit: Bool = false
    var hasClose: Bool = false
    
    // animation
    public var zoomTransition: ImagePreviewZoomTransitionDelegate = ImagePreviewZoomTransitionDelegate()
    lazy var transitionTapGesture = UITapGestureRecognizer()
    lazy var transitionPanGesture = UIPanGestureRecognizer()
    
    // UI
    lazy var fromBlurEffectView: UIView = createFromBlurEffectView()
    lazy var collectionView: UICollectionView = createCollectionView()
    lazy var indicatorView: ImagePreviewIndicatorView = createIndicatorView()
    lazy var deleteButton = createDeleteButton()
    lazy var setCoverButton = createSetCoverButton()
    lazy var stackView = createStackView()
    lazy var navBackButton = createNavBackButton()
    
    public init(inputContext: InputContext, delegate: ImagePreviewViewControllerDelegate, frameOfIndexProvider: @escaping ((Int, ImageItem?) -> CGRect)) {
        self.inputContext = inputContext
        self.frameOfIndexProvider = frameOfIndexProvider
        super.init(nibName: nil, bundle: nil)
        self.preViewIndex = inputContext.preViewIndex
        self.imageList = inputContext.imageList
        self.delegate = delegate
        setupTransitionParameter()
        transitioningDelegate = zoomTransition
        modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        setupTransitionGesture()
        bindAction()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(fromBlurEffectView)
        view.addSubview(collectionView)
        view.addSubview(indicatorView)
        view.addSubview(stackView)
        view.addSubview(navBackButton)
        
        indicatorView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(26)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        setCoverButton.snp.makeConstraints { make in
            make.width.equalTo(88)
        }
        
        stackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-5)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        
        navBackButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.width.equalTo(64)
            make.height.equalTo(32)
        }
        
        navBackButton.setHandleClick { [weak self] button in
            guard let self = self else { return }
            self.closePage()
        }
        
        setupUIConfig()
    }
    
    func setupUIConfig() {
        collectionView.reloadData()
        collectionView.setContentOffset(CGPoint(x: Int(view.bounds.width) * preViewIndex, y: 0), animated: false)
        indicatorView.reloadData(current: preViewIndex, totalCount: imageList.count)
        deleteButton.isHidden = !inputContext.showDelete
        reloadIndexAndIndicatorView()
    }
    
    func currentImageItem() -> ImageItem? {
        imageList[safe: preViewIndex]
    }
    
    func createFromBlurEffectView() -> UIView {
        let view = UIWindow.xy_keyWindow?.snapshotView(afterScreenUpdates: false) ?? UIView()
        view.frame = UIScreen.main.bounds
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blurEffectView.frame = UIScreen.main.bounds
        view.addSubview(blurEffectView)
        return view
    }
    
    func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = view.bounds.size
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isUserInteractionEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(ImagePreviewViewCell.self, forCellWithReuseIdentifier: String(describing: ImagePreviewViewCell.self))
        return collectionView
    }
    
    func createIndicatorView() -> ImagePreviewIndicatorView {
        let view = ImagePreviewIndicatorView()
        view.layer.cornerRadius = 13
        view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        return view
    }
    
    func createDeleteButton() -> UIButton {
        let view = UIButton(type: .custom)
        view.setTitle("删除", for: .normal)
        view.titleLabel?.font = UIFont.withFont(size: 14, weight: .medium)
        view.setTitleColor(UIColor.xy_hex(value: 0xFF7B7B), for: .normal)
        view.layer.cornerRadius = 20
        view.backgroundColor = UIColor.white
        view.setDefaultShadowColor()
        return view
    }
    
    func createSetCoverButton() -> UIButton {
        let view = UIButton(type: .custom)
        view.setTitle("设为封面", for: .normal)
        view.titleLabel?.font = UIFont.withFont(size: 14, weight: .medium)
        view.setTitleColor(.white, for: .normal)
        view.layer.cornerRadius = 20
        view.backgroundColor = UIColor.black
        view.setDefaultShadowColor()
        return view
    }
    
    func createNavBackButton() -> UIButton {
        let view = UIButton(type: .custom)
        view.setImage(BaseResource.image(forKey: "navi_close_icon"), for: .normal)
        return view
    }
    
    func createStackView() -> UIStackView {
        let view = UIStackView(arrangedSubviews: [deleteButton, setCoverButton])
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .fill
        view.distribution = .equalSpacing
        view.layer.masksToBounds = false
        return view
    }
}
