//
//  Restaurant.swift
//  Search_Restaurant
//
//  Created by NexStreamingCorp on 1/18/16.
//  Copyright © 2016 NexStreamingCorp. All rights reserved.
//

import UIKit

class Restaurant: NSObject, NSCoding {

	// MARK: properties

	var name: String
	var photo: UIImage?
	var address: String
	var checkins: UInt
	var latitude: String
	var longitude: String
	var venue_id: String

	// MARK: Archiving Paths

	static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
	static let archiveURL = documentsDirectory.appendingPathComponent("restaurants")

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

	init?(name: String, photo: UIImage?, address: String, checkins: UInt, latitude: String,
	      longitude: String, venue_id: String) {
		self.name = name
		self.photo = photo
		self.address = address
		self.checkins = checkins
		self.latitude = latitude
		self.longitude = longitude
		self.venue_id = venue_id

		super.init()

		// Initialization should fail if there is no name.
		if name.isEmpty {
			return nil
		}
	}

	// MARK: NSCoding

	func encode(with aCoder: NSCoder) {
		aCoder.encode(name, forKey: PropertyKey.nameKey)
		aCoder.encode(photo, forKey: PropertyKey.photoKey)
		aCoder.encode(address, forKey: PropertyKey.addressKey)
		aCoder.encode(checkins, forKey: PropertyKey.checkinsKey)
		aCoder.encode(latitude, forKey: PropertyKey.latitudeKey)
		aCoder.encode(longitude, forKey: PropertyKey.longitudeKey)
		aCoder.encode(venue_id, forKey: PropertyKey.venueIdKey)
	}

	required convenience init?(coder aDecoder: NSCoder) {
		guard let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as? String,
		      let address = aDecoder.decodeObject(forKey: PropertyKey.addressKey) as? String,
		      let lat = aDecoder.decodeObject(forKey: PropertyKey.latitudeKey) as? String,
		      let lng = aDecoder.decodeObject(forKey: PropertyKey.longitudeKey) as? String,
		      let venueId = aDecoder.decodeObject(forKey: PropertyKey.venueIdKey) as? String
		else {
			return nil
		}

		let photo = aDecoder.decodeObject(forKey: PropertyKey.photoKey) as? UIImage
		let checkins = (aDecoder.decodeObject(forKey: PropertyKey.checkinsKey) as? UInt) ?? 0

		self.init(name: name, photo: photo, address: address, checkins: checkins,
		          latitude: lat, longitude: lng, venue_id: venueId)
	}
}
