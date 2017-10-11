//
//  UIViewController + Ex.swift
//  TrackMe
//
//  Created by KhanhND on 10/11/17.
//  Copyright © 2017 KhanhND. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlertView(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style:.default) { (action) in
        }
        alertController.addAction(okAction)
        let presentedVC = UIApplication.shared.keyWindow?.rootViewController
        presentedVC!.present(alertController, animated: true, completion: nil)
    }
}
