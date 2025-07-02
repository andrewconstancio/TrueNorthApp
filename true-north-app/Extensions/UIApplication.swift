//
//  UIApplication.swift
//  true-north-app
//
//  Created by Andrew Constancio on 6/25/25.
//
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
