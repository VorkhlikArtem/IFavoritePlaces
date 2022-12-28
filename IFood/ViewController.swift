//
//  ViewController.swift
//  IFood
//
//  Created by Артём on 24.12.2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let ratingControl = RatingControl()
        ratingControl.backgroundColor = .cyan
        ratingControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ratingControl)
        ratingControl.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        ratingControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }


}

//MARK: - SwiftUI
import SwiftUI
struct ViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().ignoresSafeArea(.all)
    }
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = ViewController()
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return viewController
        }
    }
}
