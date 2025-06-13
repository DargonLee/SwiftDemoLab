//
//  ImagePreviewZoomTransitionAnimator.swift
//  SLFoundation
//
//  Created by fenglianyi on 2024/6/24.
//

import UIKit

class ImagePreviewZoomInTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var transitionParameter: ImagePreviewTransitionParameter
    
    init(transitionParameter: ImagePreviewTransitionParameter) {
        self.transitionParameter = transitionParameter
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let containerView = transitionContext.containerView
        guard let toView = toVC.view else {
            return
        }
        
        containerView.addSubview(toView)
        let containerBounds = containerView.bounds
        
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blurEffectView.frame = containerBounds
        blurEffectView.alpha = 0
        containerView.addSubview(blurEffectView)
        
        let transitionImageView = UIImageView(image: transitionParameter.transitionImage)
        transitionImageView.frame = transitionParameter.fromFrame
        transitionImageView.clipsToBounds = true
        transitionImageView.contentMode = .scaleAspectFill
        containerView.addSubview(transitionImageView)
        
        toView.isHidden = true
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            transitionImageView.frame = self.transitionParameter.toFrame
            blurEffectView.alpha = 1
        }) { _ in
            toView.isHidden = false
            transitionImageView.removeFromSuperview()
            blurEffectView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

class ImagePreviewZoomOutTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var transitionParameter: ImagePreviewTransitionParameter
    
    init(transitionParameter: ImagePreviewTransitionParameter) {
        self.transitionParameter = transitionParameter
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        guard let toView = toVC.view else {
            return
        }
        
        let containerBounds = containerView.bounds
        
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blurEffectView.frame = containerBounds
        containerView.addSubview(blurEffectView)
        
        let transitionImageView = UIImageView(image: transitionParameter.transitionImage)
        transitionImageView.frame = transitionParameter.toFrame
        transitionImageView.contentMode = .scaleAspectFill
        transitionImageView.clipsToBounds = true
        containerView.addSubview(transitionImageView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            blurEffectView.alpha = 0
            transitionImageView.frame = self.transitionParameter.fromFrame
            fromVC.view.isHidden = true
        }) { _ in
            blurEffectView.removeFromSuperview()
            transitionImageView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

