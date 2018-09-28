//
//  Extensions.swift
//  GuestlogixTest
//
//  Created by Byung Yoo on 2018-09-28.
//  Copyright © 2018 Theta Labs Inc. All rights reserved.
//

import Foundation
import UIKit
// contains all other extensions 


// method to close the keyboard when anywhere else on the screen outside of textboxes are tapped
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}




extension String {
    
    // checks for empty strings after trimming
    var isEmptyTrimmed: Bool {
        return self.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
    }
    
    // returns strings with whitespaces trimmed
    var trimmed : String{
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
}
