//
//  ItemTableViewCell.swift
//  ShoppingList
//
//  Created by Sagitova Gulnaz on 03.02.17.
//  Copyright © 2017 Sagitova Gulnaz. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet var boughtButton: UIButton!
    @IBOutlet var itemName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
