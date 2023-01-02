//
//  VC + Extension.swift
//  IFood
//
//  Created by Артём on 02.01.2023.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
       
        alertController.addAction(ok)
     
        present(alertController, animated: true, completion: nil)
    }
}
