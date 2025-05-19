//
//  ViewController.swift
//  SwiftDemoLab
//
//  Created by lihailong on 2025/5/19.
//

import UIKit
import Inject

#if DEBUG
extension UIViewController {
    @objc func injected() {
        viewDidLoad()
    }
}
#endif

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let viewController = Inject.ViewControllerHost(TestViewController())
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

