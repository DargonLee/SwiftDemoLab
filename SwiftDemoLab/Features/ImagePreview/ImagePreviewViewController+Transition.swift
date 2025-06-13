//
//  ImagePreviewViewController+Transition.swift
//  SLFoundation
//
//  Created by fenglianyi on 2024/6/24.
//

import Foundation

extension ImagePreviewViewController {
    func setupTransitionParameter() {
        zoomTransition.transitionParameter.transitionImage = inputContext.transitionImage
        zoomTransition.transitionParameter.fromFrame = self.frameOfIndexProvider(self.preViewIndex, currentImageItem())
        let imageWidth = max(inputContext.transitionImage.size.width, 1)
        let imageHeight = max(inputContext.transitionImage.size.height, 1)
        let toHeight = imageHeight/imageWidth * screenWidth
        let y = max((screenHeight - toHeight)/2, 0)
//        toHeight = min(toHeight, screenHeight)
        zoomTransition.transitionParameter.toFrame = CGRect(x: 0, y: y, width: screenWidth, height: toHeight)
    }
    
    func setupTransitionGesture() {
        view.addGestureRecognizer(transitionTapGesture)
        transitionTapGesture.addTarget(self, action: #selector(transitionTapGestureAction))
        
        view.addGestureRecognizer(transitionPanGesture)
        transitionPanGesture.addTarget(self, action: #selector(interactiveTransitionRecognizerAction(panGes:)))
    }
    
    func setupFromVisualEffectView(view: UIView) {
        view.addSubview(view)
        view.isUserInteractionEnabled = false
    }
    
    @objc
    func transitionTapGestureAction() {
        closePage()
    }
    
    @objc
    func interactiveTransitionRecognizerAction(panGes: UIPanGestureRecognizer) {
        let translatePoint = panGes.translation(in: view)
        let scale = min(1, max(0, 1 - translatePoint.y / view.xy_height))
        if panGes.state == .changed {
            if scale > 0.5 {
                closePage()
            }
        }
    }
    
    func closePage() {
        guard !hasClose else {
            return
        }
        
        hasClose = true
        
        if hasEdit {
            finallyImageListHandle?(imageList)
            delegate?.imagePreviewFinallyImageList(self, items: imageList)
        }
        
        self.preViewIndex = Int(self.collectionView.contentOffset.x/self.view.bounds.width)
        self.zoomTransition.transitionParameter.fromFrame = self.frameOfIndexProvider(self.preViewIndex, self.currentImageItem())
        if let cell = self.collectionView.cellForItem(at: IndexPath(row: self.preViewIndex, section: 0)) as? ImagePreviewViewCell {
            if let image = cell.animationImage {
                self.zoomTransition.transitionParameter.transitionImage = image
            }
            self.zoomTransition.transitionParameter.toFrame = cell.animationRect
        }
        DispatchQueue.main.async {
            self.dismiss(animated: true)
            self.hasClose = false
        }
    }
}

extension ImagePreviewViewController: UIViewControllerTransitioningDelegate {
    
}
