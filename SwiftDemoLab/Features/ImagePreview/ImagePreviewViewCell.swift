//
//  ImagePreviewViewCell.swift
//  SLFoundation
//
//  Created by fenglianyi on 2024/6/24.
//

import UIKit
import RxCocoa
import RxSwift
import SLDataModel
import SDWebImage

class ImagePreviewViewCell: UICollectionViewCell {
    var closeHandler: VoidClosure?
    
    private lazy var scrollView = createScrollView()
    private lazy var imageView = createImageView()

    private var doingZoom = false
    private var doingTransition = false
    private var panLastY: CGFloat = 0

    private let bag = DisposeBag()
    
    var animationImage: UIImage? {
        imageView.image
    }
    
    var animationRect: CGRect {
        scrollView.zoomScale = 1
        return imageView.frame
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        contentView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView.addSubview(imageView)
        contentView.layoutIfNeeded()
    }
    
    func bindData(item: ImageItem) {
        if let image = item.image {
            renderImageView(image)
        } else {
            if let img = SDImageCache.shared.imageFromDiskCache(forKey: item.url) {
                self.renderImageView(img)
            } else {
                showLoading()
                imageView.sd_setImage(with: URL(string: item.url), placeholderImage: item.image) { [weak self] image, _, type, _ in
                    guard let self = self else { return }
                    hideLoading()
                    self.renderImageView(image)
                }
            }
        }
        scrollView.zoomScale = 1
    }
    
    func renderImageView(_ image: UIImage?) {
        guard let image = image else {
            return
        }
        let imageWidth = max(image.size.width, 1)
        let imageHeight = max(image.size.height, 1)
        let contentWidth = contentView.xy_width
        let contentHeight = contentView.xy_height
        let targetHeight = contentWidth / imageWidth * imageHeight
        let targetCenterY = targetHeight >= contentHeight ? targetHeight * 0.5 : contentHeight * 0.5

        imageView.image = image
        imageView.bounds = CGRect(x: 0, y: 0, width: contentWidth, height: targetHeight)
        imageView.center = CGPoint(x: contentView.xy_xCenter, y: targetCenterY)
        scrollView.contentSize = imageView.xy_size
    }

    func reset() {
        scrollView.zoomScale = 1
        panLastY = 0
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            guard let self = self else {
                return
            }
            self.closeHandler?()
        }).disposed(by: bag)
        contentView.addGestureRecognizer(tap)

        let twiceTap = UITapGestureRecognizer()
        twiceTap.numberOfTapsRequired = 2
        twiceTap.rx.event.subscribe(onNext: { [weak self] ges in
            guard let self = self else {
                return
            }
            let scale = self.scrollView.zoomScale
            if scale > 1.0 {
                self.scrollView.setZoomScale(1.0, animated: true)
                return
            }
            let point = ges.location(in: self.imageView)
            let width = self.contentView.xy_width / 3
            let height = self.contentView.xy_height / 3
            let x = point.x - width * 0.5
            let y = point.y - height * 0.5
            self.scrollView.zoom(to: CGRect(x: x, y: y, width: width, height: height), animated: true)
        }).disposed(by: bag)
        contentView.addGestureRecognizer(twiceTap)

        tap.require(toFail: twiceTap)
    }
    
    private func createScrollView() -> UIScrollView {
        let scroll = UIScrollView(frame: CGRect.zero)
        scroll.delegate = self
        scroll.maximumZoomScale = 5
        scroll.minimumZoomScale = 1
        scroll.zoomScale = 1
        scroll.scrollsToTop = false
        scroll.bouncesZoom = true
        scroll.isMultipleTouchEnabled = true
        scroll.alwaysBounceVertical = false
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.contentSize = CGSize(width: screenWidth, height: screenWidth)
        return scroll
    }
    
    private func createImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }
}

extension ImagePreviewViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = center(of: scrollView)
        doingZoom = false
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        doingZoom = true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < contentView.bounds.height * -0.2 && !doingTransition && !doingZoom {
            triggerTransitionIfNeed(scrollView.panGestureRecognizer)
        }
    }

    func scrollViewDidEndDecelerating(_: UIScrollView) {
        doingTransition = false
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        doingTransition = false
    }

    private func triggerTransitionIfNeed(_ panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .ended ||
            panGesture.state == .possible ||
            panGesture.state == .cancelled {
            doingTransition = false
            return
        }
        if panGesture.numberOfTouches != 1 || doingZoom {
            doingTransition = false
            return
        }
        let currentY = panGesture.location(in: self).y
        debugPrint("hl:---currentY\(currentY),panLastY\(panLastY)")
        let isDirectionDown = currentY > panLastY
        panLastY = currentY
        if !doingTransition && isDirectionDown {
            self.doingTransition = true
            closeHandler?()
        }
    }

    private func center(of scrollView: UIScrollView) -> CGPoint {
        let boundsWidth = scrollView.bounds.size.width
        let contentWith = scrollView.contentSize.width
        let boundsHeihgt = scrollView.bounds.size.height
        let contentHeight = scrollView.contentSize.height
        let offsetX = boundsWidth > contentWith ? (boundsWidth - contentWith) * 0.5 : 0
        let offsetY = boundsHeihgt > contentHeight ? (boundsHeihgt - contentHeight) * 0.5 : 0
        let center = CGPoint(x: contentWith * 0.5 + offsetX, y: contentHeight * 0.5 + offsetY)
        return center
    }
}
