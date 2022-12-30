//
//  MainCell.swift
//  IFood
//
//  Created by Артём on 28.12.2022.
//

import UIKit
import Cosmos

class MainCell: UITableViewCell {
    
    
    @IBOutlet weak var placeImageView: UIImageView! {
        didSet {
            placeImageView.layer.cornerRadius = placeImageView.frame.size.height / 2
            placeImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
}
