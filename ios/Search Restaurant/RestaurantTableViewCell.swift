//
//  RestaurantTableViewCell.swift
//  Search_Restaurant
//
//  Created by NexStreamingCorp on 1/18/16.
//  Copyright © 2016 NexStreamingCorp. All rights reserved.
//

import Foundation
import UIKit

class RestaurantTableViewCell: UITableViewCell {
	
	
	@IBOutlet weak var restaurantImage: UIImageView!
	@IBOutlet weak var restaurantName: UILabel!
	@IBOutlet weak var restaurantAddress: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	
	}
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}
