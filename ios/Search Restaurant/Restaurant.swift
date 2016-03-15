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
    var checkins: UInt!
    var latitude: String
    var longitude: String
    var venue_id : String
	
	
	// MARK: Archiving Paths
	
	static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
	static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("restaurants")
	
	// MARK: Types
	
	struct PropertyKey {
		static let nameKey = "name"
		static let photoKey = "photo"
		static let addressKey = "address"
        static let checkinsKey = "checkins"
        static let latitudeKey = "lat"
        static let longitudeKey = "lng"
        static let venueIdKey = "venue_id"
	}
	
	// MARK: Initialization
	
    init?(name: String, photo: UIImage?, address: String,checkins: UInt!, latitude:String,
        longitude: String,venue_id:String) {
            // Initialize stored properties.
            self.name = name
            self.photo = photo
            self.address = address
            self.checkins = checkins
            self.latitude = latitude
            self.longitude = longitude
            self.venue_id = venue_id
		
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
        aCoder.encodeObject(checkins,forKey: PropertyKey.checkinsKey)
        aCoder.encodeObject(latitude, forKey: PropertyKey.latitudeKey)
        aCoder.encodeObject(longitude, forKey: PropertyKey.longitudeKey)
        aCoder.encodeObject(venue_id, forKey: PropertyKey.venueIdKey)
	}
	
	required convenience init?(coder aDecoder: NSCoder) {
		let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
		
		// Because photo is an optional property of Meal, use conditional cast.
		let photo = aDecoder.decodeObjectForKey(PropertyKey.photoKey) as? UIImage
		
		let address = aDecoder.decodeObjectForKey(PropertyKey.addressKey) as! String
        
        let checkins = aDecoder.decodeObjectForKey(PropertyKey.checkinsKey) as! UInt
        
        let lat = aDecoder.decodeObjectForKey(PropertyKey.latitudeKey) as! String
        let lng = aDecoder.decodeObjectForKey(PropertyKey.longitudeKey) as! String
		let venueId = aDecoder.decodeObjectForKey(PropertyKey.venueIdKey) as! String
        
		// Must call designated initializer.
        self.init(name: name, photo: photo, address: address,checkins: checkins, latitude:lat,
            longitude: lng,venue_id:venueId)
	}


}
