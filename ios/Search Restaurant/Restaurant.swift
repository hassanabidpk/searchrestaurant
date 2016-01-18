//
//  Restaurant.swift
//  Search_Restaurant
//
//  Created by NexStreamingCorp on 1/18/16.
//  Copyright © 2016 NexStreamingCorp. All rights reserved.
//

import UIKit

class Restaurant: NSObject,NSCoding {

	// MARK: properties 
	
	var name: String
	var photo: UIImage?
	var address: String
	
	
	// MARK: Archiving Paths
	
	static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
	static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("restaurants")
	
	// MARK: Types
	
	struct PropertyKey {
		static let nameKey = "name"
		static let photoKey = "photo"
		static let addressKey = "address"
	}
	
	// MARK: Initialization
	
	init?(name: String, photo: UIImage?, address: String) {
		// Initialize stored properties.
		self.name = name
		self.photo = photo
		self.address = address
		
		super.init()
		
		// Initialization should fail if there is no name
		if name.isEmpty {
			return nil
		} else {
			print("restaurant \(name): saved")
		}
	}
	
	// MARK: NSCoding
	
	func encodeWithCoder(aCoder: NSCoder) {
		print("encodeWithCoder")
		aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
		aCoder.encodeObject(photo, forKey: PropertyKey.photoKey)
		aCoder.encodeObject(address, forKey: PropertyKey.addressKey)
	}
	
	required convenience init?(coder aDecoder: NSCoder) {
		let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
		
		// Because photo is an optional property of Meal, use conditional cast.
		let photo = aDecoder.decodeObjectForKey(PropertyKey.photoKey) as? UIImage
		
		let address = aDecoder.decodeObjectForKey(PropertyKey.addressKey) as! String
		
		// Must call designated initializer.
		self.init(name: name, photo: photo, address: address)
	}


}
