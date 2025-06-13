//
//  SharedElementTransitionAnimator.swift
//  TestBlurView
//
//  Created by lihailong on 2025/5/19.
//

import UIKit

public class SharedElementTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.4
    var operation: UINavigationController.Operation = .push

    public func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        duration
    }

    public func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        switch operation {
        case .push: animatePush(using: transitionContext)
        case .pop:  animatePop(using: transitionContext)
        default:    transitionContext.completeTransition(false)
        }
    }
    
    // MARK: - PUSH
    private func animatePush(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let sourceVC = fromVC as? SharedElementTransitionProtocolsSource,
              let destinationVC = toVC as? SharedElementTransitionProtocolsDestination else {
            performFallbackAnimation(using: transitionContext, fromView: transitionContext.viewController(forKey: .from)?.view, toView: transitionContext.viewController(forKey: .to)?.view, in: transitionContext.containerView)
            return
        }
        let containerView = transitionContext.containerView
        let sourceView = sourceVC.sharedView
        let destinationView = destinationVC.targetSharedView
        
        let cardView = sourceVC.cardView
        let emojisView = sourceVC.emojisView

        containerView.addSubview(toVC.view)
        toVC.view.layoutIfNeeded()
        
        let destinationFrameInContainer = destinationView.convert(destinationView.bounds, to: containerView)
        
        let snapshotView = sourceVC.makeSharedViewSnapshot as! UILabel
        snapshotView.frame = sourceView.convert(sourceView.bounds, to: containerView)
        containerView.addSubview(snapshotView)

        sourceView.isHidden = true
        destinationView.isHidden = true
        toVC.view.alpha = 0.0

        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseInOut]) {
            snapshotView.frame = destinationFrameInContainer
            snapshotView.layer.cornerRadius = destinationView.layer.cornerRadius
            if #available(iOS 17.0, *) {
                snapshotView.font = UIFont.systemFont(ofSize: 26)
            }
            cardView.transform = CGAffineTransform(translationX: 0, y: 20)
            emojisView.transform = CGAffineTransform(translationX: 0, y: 20)
            toVC.view.alpha = 1.0
            fromVC.view.alpha = 0.0
        } completion: { finished in
            let success = !transitionContext.transitionWasCancelled
            snapshotView.removeFromSuperview()
            destinationView.isHidden = false
            if success {
                // push结束
                sourceView.isHidden = true
            } else {
                sourceView.isHidden = false
                destinationView.isHidden = true
                toVC.view.removeFromSuperview()
            }
            fromVC.view.alpha = 1.0
            transitionContext.completeTransition(success)
        }
    }
    
    // MARK: - POP
    private func animatePop(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let sourceVC = toVC as? SharedElementTransitionProtocolsSource,
              let destinationVC = fromVC as? SharedElementTransitionProtocolsDestination else {
            performFallbackAnimation(using: transitionContext, fromView: transitionContext.viewController(forKey: .from)?.view, toView: transitionContext.viewController(forKey: .to)?.view, in: transitionContext.containerView)
            return
        }
        let containerView = transitionContext.containerView
        let sourceView = destinationVC.targetSharedView
        let destinationView = sourceVC.sharedView
        
        let cardView = sourceVC.cardView
        let emojisView = sourceVC.emojisView

        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        toVC.view.layoutIfNeeded()
        
        let oriFrame = destinationView.convert(destinationView.bounds, to: containerView)
        let destinationFrameInContainer = oriFrame.offsetBy(dx: 0, dy: -20)
        
        let snapshotView = destinationVC.makeSharedViewSnapshot as! UILabel
        snapshotView.frame = sourceView.convert(sourceView.bounds, to: containerView)
        containerView.addSubview(snapshotView)


        sourceView.isHidden = true
        destinationView.isHidden = true
        toVC.view.alpha = 0.0
        toVC.view.isHidden = false
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseInOut]) {
            snapshotView.frame = destinationFrameInContainer
            snapshotView.layer.cornerRadius = destinationView.layer.cornerRadius
            if #available(iOS 17.0, *) {
                snapshotView.font = UIFont.systemFont(ofSize: 34)
            }
            cardView.transform = .identity
            emojisView.transform = .identity
            fromVC.view.alpha = 0.0
            toVC.view.alpha = 1.0
        } completion: { finished in
            let success = !transitionContext.transitionWasCancelled
            snapshotView.removeFromSuperview()
            if success {
                sourceView.isHidden = false
                destinationView.isHidden = false
            } else {
                sourceView.isHidden = false
                destinationView.isHidden = true
            }
            transitionContext.completeTransition(success)
        }
    }
    
    // MARK: - 后备动画
    private func performFallbackAnimation(using transitionContext: UIViewControllerContextTransitioning?, fromView: UIView?, toView: UIView?, in containerView: UIView) {
        guard let toView = toView else {
            transitionContext?.completeTransition(false)
            return
        }
        containerView.addSubview(toView)
        toView.alpha = 0.0
        
        UIView.animate(withDuration: duration, animations: {
            toView.alpha = 1.0
            if self.operation == .push {
                fromView?.alpha = 0.0
            }
        }) { (_) in
            if !(transitionContext?.transitionWasCancelled ?? true) {
                fromView?.alpha = 1.0
            } else {
                toView.removeFromSuperview()
                fromView?.alpha = 1.0
            }
            transitionContext?.completeTransition(!(transitionContext?.transitionWasCancelled ?? true))
        }
    }
}
