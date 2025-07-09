//
//  UINavigationController.swift
//  true-north-app
//
//  Created by Andrew Constancio on 7/8/25.
//
import UIKit

extension UINavigationController {
    // Remove back button text
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
