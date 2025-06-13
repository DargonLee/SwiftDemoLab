//
//  InteractiveTransitionController.swift
//  TestBlurView
//
//  Created by lihailong on 2025/5/19.
//

import UIKit

public class InteractiveTransitionController: UIPercentDrivenInteractiveTransition {
    var isInteractive = false
    
    public override func finish() {
        completionSpeed = 1.0 - percentComplete
        super.finish()
        isInteractive = false
    }
    
    public override func cancel() {
        completionSpeed = percentComplete
        super.cancel()
        isInteractive = false
    }
    
    public override func update(_ percentComplete: CGFloat) {
        super.update(max(0.0, min(1.0, percentComplete)))
    }
}
