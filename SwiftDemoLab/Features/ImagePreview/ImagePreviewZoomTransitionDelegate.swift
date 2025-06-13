//
//  ImagePreviewZoomTransitionDelegate.swift
//  SLFoundation
//
//  Created by fenglianyi on 2024/6/24.
//

import UIKit

public class ImagePreviewZoomTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    public var transitionParameter: ImagePreviewTransitionParameter = ImagePreviewTransitionParameter()
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ImagePreviewZoomInTransitionAnimator(transitionParameter: transitionParameter)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ImagePreviewZoomOutTransitionAnimator(transitionParameter: transitionParameter)
    }
}
