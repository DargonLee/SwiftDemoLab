//
//  SharedElementTransitionProtocols.swift
//  TestBlurView
//
//  Created by lihailong on 2025/5/19.
//

import UIKit

public protocol SharedElementTransitionProtocolsSource: UIViewController {
    var sharedView: UIView { get }
    var cardView: UIView { get }
    var emojisView: UIView { get }
    var makeSharedViewSnapshot: UIView { get }
}

public protocol SharedElementTransitionProtocolsDestination: UIViewController {
    var targetSharedView: UIView { get }
    var makeSharedViewSnapshot: UIView { get }
}

