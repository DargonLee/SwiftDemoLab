//
//  RunningNavigationControllerDelegate.swift
//  TestBlurView
//
//  Created by lihailong on 2025/5/19.
//

import UIKit

public class SharedElementTransitionNavDelegate: NSObject, UINavigationControllerDelegate {
    
    var interactiveTransition: UIPercentDrivenInteractiveTransition?
    
    public func navigationController(_ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        let isSourceCompatible: Bool
        let isDestinationCompatible: Bool
        
        switch operation {
        case .push:
            isSourceCompatible = fromVC is SharedElementTransitionProtocolsSource
            isDestinationCompatible = toVC is SharedElementTransitionProtocolsDestination
        case .pop:
            isSourceCompatible = toVC is SharedElementTransitionProtocolsSource
            isDestinationCompatible = fromVC is SharedElementTransitionProtocolsDestination
        default:
            return nil
        }
        if isSourceCompatible && isDestinationCompatible {
            let animator = SharedElementTransitionAnimator()
            animator.operation = operation
            return animator
        }
        return nil
    }
    
    public func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard animationController is SharedElementTransitionAnimator else { return nil }
        return interactiveTransition
    }
}

