//
//  ViewController.swift
//  Search Restaurant
//
//  Created by NexStreamingCorp on 1/4/16.
//  Copyright © 2016 NexStreamingCorp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	let GOOGLE_API_KEY = "API_KEY"
	let FOURSQUARE_CLIENT_ID = "CLIENT_ID"
	let FOURSQUARE_CLIENT_SECRET = "CLIENT_SECRET"
	let GOOGLE_BASE_URL_HOST = "maps.googleapis.com"
	let FOURSQUARE_BASE_URL_HOST = "api.foursquare.com"
	
	

	
	@IBOutlet weak var restaurantImageView: UIImageView!
	@IBOutlet weak var restaurantName: UILabel!
	
	@IBOutlet weak var locationTextField: UITextField!
	@IBOutlet weak var restaurantTextField: UITextField!
	
	@IBOutlet weak var restaurantAddress: UILabel!
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	@IBOutlet weak var restaurantCheckins: UILabel!
	
	var tapRecognizer: UITapGestureRecognizer? = nil
	
	@IBAction func searchRestaurant(sender: UIButton) {
		
		print("search restaurant")
		self.dismissAnyVisibleKeyboards()
		if !self.locationTextField.text!.isEmpty && !self.restaurantTextField.text!.isEmpty {
			self.restaurantName.text = "Searching .... "
			self.restaurantCheckins.text = ""
			self.restaurantAddress.text = ""
			self.spinner.startAnimating()
			let gURL = self.getURLForQuery()
			print(gURL)
	
			self.getLocationCordinates(gURL)
		} else {
		
			self.restaurantName.text = "Enter both location and restaurant type!"
			self.restaurantCheckins.text = ""
			self.restaurantAddress.text = ""
		}
	
	
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	
		tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
		tapRecognizer?.numberOfTapsRequired = 1
		self.restaurantCheckins.text = ""
		self.restaurantAddress.text = ""
		self.spinner.stopAnimating()
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		self.addKeyboardDismissRecognizer()
		self.subscribeKeyboardNotifications()
	}
	
	override func viewWillDisappear(animated: Bool) {
		self.viewWillDisappear(animated)
		
		self.removeKeyboardDismissRecognizer()
		self.unsubscribeKeyboardNotifications()
	}
	
	
	func getURLForQuery() -> NSURL {
		
		let googleComponents = NSURLComponents()
		googleComponents.scheme = "https"
		googleComponents.host = GOOGLE_BASE_URL_HOST
		googleComponents.path = "/maps/api/geocode/json"
		let queryString = self.locationTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "+")
		let addressItem = NSURLQueryItem(name: "address", value: queryString)
		let keyItem = NSURLQueryItem (name: "key", value: GOOGLE_API_KEY)
		
		googleComponents.queryItems = [addressItem,keyItem]
		let url = googleComponents.URL! as NSURL
		
		return url
	
	}
	
	func getLocationCordinates(url : NSURL) {
		
		let session = NSURLSession.sharedSession()
		let request = NSURLRequest(URL: url)
		
		let task = session.dataTaskWithRequest(request) { (data, response, error) in
		
			guard (error == nil ) else {
				print("There is error in Google Geo-coding api request")
				return
			}
			
			guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
				
				if let response = response as? NSHTTPURLResponse {
					print ("Your Google geocoding request returned an Invalid response! Status code : \(response.statusCode)")
				} else if let response = response {
					print ("Your Google geocoding request returned an Invalid response! Response : \(response)")
				} else {
					print ("Your Google geocoding request returned an Invalid response!")
				}
				
				return
			}
			
			guard let data = data else {
			
				print("No data was returned by the request")
				return
			}
			
			
			let parsedResult : AnyObject!
			
			do {
				parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
			}catch {
				
				parsedResult = nil
				print("Could not parse the data as JSON : \(data)")
				return
			}
			
			
			guard let stat = parsedResult["status"] as? String where stat == "OK" else {
				print ("Google geocoding API returned an error = See error code in \(parsedResult)")
                self.stopSpinner(parsedResult["status"] as! String)
				return
			}
			
			guard let results = parsedResult["results"] as? NSArray, first = results[0] as? NSDictionary,
			 geometry = first["geometry"] as? NSDictionary,
			 location = geometry["location"] as! NSDictionary?
				else {
				print ("cannot find key location in \(parsedResult)")
				return
			}
			
			print(location)
			if let latitude = location["lat"], longitude = location["lng"] {
			
				self.getRandomRestaurant("\(latitude)", lng:  "\(longitude)")
			} else {
				print("latitude or longitude are nil")
				return
			}
			
		
		}
		
		task.resume()
		
		
	
	}
	
	func getRandomRestaurant(lat:String! , lng: String!)  {
		
		let foursquareComponents = NSURLComponents()
		foursquareComponents.scheme = "https"
		foursquareComponents.host = FOURSQUARE_BASE_URL_HOST
		foursquareComponents.path = "/v2/venues/search"
		
		let clientid = NSURLQueryItem(name: "client_id", value: FOURSQUARE_CLIENT_ID)
		let clientsecret = NSURLQueryItem(name: "client_secret", value: FOURSQUARE_CLIENT_SECRET)
		let version = NSURLQueryItem(name: "v", value: "20160105")
		let limit = NSURLQueryItem(name: "limit", value: "50")
		var latlongStr :String
		if let latitude = lat as String!, longitude = lng as String! {
			latlongStr = String(latitude) + "," + String(longitude)
		} else {
			latlongStr = ""
		}
//		let escapedRestaurantValue = self.restaurantTextField.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
		let escapedRestaurantValue = "\(self.restaurantTextField.text!)"
		let latlong = NSURLQueryItem(name: "ll", value: latlongStr)
		let query = NSURLQueryItem(name: "query", value: escapedRestaurantValue)
		
		foursquareComponents.queryItems = [clientid,clientsecret, version,limit,latlong,query]
		let url = foursquareComponents.URL! as NSURL
		
		print(url)
		
		let session = NSURLSession.sharedSession()
		let request = NSURLRequest(URL: url)
		
		let task = session.dataTaskWithRequest(request) { (data, response, error) in
			
			guard (error == nil ) else {
				print("There is error in Google Geo-coding api request")
				return
			}
			
			guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
				
				if let response = response as? NSHTTPURLResponse {
					print ("Your Google geocoding request returned an Invalid response! Status code : \(response.statusCode)")
				} else if let response = response {
					print ("Your Google geocoding request returned an Invalid response! Response : \(response)")
				} else {
					print ("Your Google geocoding request returned an Invalid response!")
				}
				
				return
			}
			
			guard let data = data else {
				
				print("No data was returned by the request")
				return
			}
			
			
			let parsedResult : AnyObject!
			
			do {
				parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
			}catch {
				
				parsedResult = nil
				print("Could not parse the data as JSON : \(data)")
				return
			}
			
			
			guard let meta = parsedResult["meta"] as! NSDictionary?, stat = meta["code"] as? Int where stat == 200 else {
				print ("Google geocoding API returned an error = See error code in \(parsedResult)")
				return
			}
			
			guard let response = parsedResult["response"] as? NSDictionary, venues = response["venues"] as? NSArray where venues.count >= 1
				else {
					print ("cannot find key restaurant in \(parsedResult)")
					dispatch_async(dispatch_get_main_queue(), {
						self.restaurantName.text = "Coudn't find any restaurant - Try again"
						self.spinner.stopAnimating()
						
					})
					return
			}
			
			let venueCount = venues.count
			print(venues.count)
			let venueLimit = min(venueCount, 50)
			let randomRestaurant = Int(arc4random_uniform(UInt32(venueLimit)))
			
			if let restaurant = venues[randomRestaurant] as? NSDictionary {
					let location = restaurant["location"]!
					let formattedAddress = location["formattedAddress"]
				    let stats = restaurant["stats"]!
					let name = restaurant["name"]!
					let id = restaurant["id"]
					let checkIns = stats["checkinsCount"]
					
					print(name, " \nAddress : " , formattedAddress, "\nstats: ", checkIns)
				if let venueId = id as! String! {
					self.getRandomPhoto(venueId)
					var checkInsCount : Int
					if let checkins = checkIns  {
						checkInsCount = checkins as! Int
					} else {
						checkInsCount = 0
					}
					
					dispatch_async(dispatch_get_main_queue(), {
						self.restaurantName.font = UIFont.systemFontOfSize(20.0)
						
						self.restaurantName.text = (name as! String)
						self.restaurantCheckins.text = "Checkins : \(checkInsCount)"
						var addressArray =  [String]()
						if let address = formattedAddress {
							addressArray = address as! [String]
							print("Formatted address: ", addressArray)
							self.restaurantAddress.lineBreakMode = NSLineBreakMode.ByWordWrapping
							self.restaurantAddress.numberOfLines = 0
						
							self.restaurantAddress.text = addressArray.joinWithSeparator(" ")
						}
					})

				}
				
				}
			
			
			
		}
		
		task.resume()
		
		
	}
    
    func stopSpinner(error : String!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.spinner.stopAnimating()
            if let error = error {
                self.restaurantName.text = error
            }
        })
    }
	
	func getRandomPhoto(id : String!)  {
		
		let foursquareComponents = NSURLComponents()
		foursquareComponents.scheme = "https"
		foursquareComponents.host = FOURSQUARE_BASE_URL_HOST
		var venueID :String
		if let venueId = id as String! {
			venueID = venueId;
			print(venueID, " venueid : " , venueId)
		} else {
			print("venue Id is nil ")
			return
		}
		foursquareComponents.path = "/v2/venues/"+venueID+"/photos"
		
		let clientid = NSURLQueryItem(name: "client_id", value: FOURSQUARE_CLIENT_ID)
		let clientsecret = NSURLQueryItem(name: "client_secret", value: FOURSQUARE_CLIENT_SECRET)
		let version = NSURLQueryItem(name: "v", value: "20160105")
		

		
		foursquareComponents.queryItems = [clientid,clientsecret, version]
		let url = foursquareComponents.URL! as NSURL
		
		print(url)
		
		let session = NSURLSession.sharedSession()
		let request = NSURLRequest(URL: url)
		
		let task = session.dataTaskWithRequest(request) { (data, response, error) in
			
			guard (error == nil ) else {
				print("There is error in Foursquare Photo request api request")
				self.spinner.stopAnimating()
				return
			}
			
			guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
				
				if let response = response as? NSHTTPURLResponse {
					print ("Your Foursquare photo request returned an Invalid response! Status code : \(response.statusCode)")
				} else if let response = response {
					print ("Your Foursquare photo request returned an Invalid response! Response : \(response)")
				} else {
					print ("Your Foursquare photo  request returned an Invalid response!")
				}
				self.spinner.stopAnimating()
				return
			}
			
			guard let data = data else {
				
				print("No data was returned by the Foursquare photo  request")
				self.spinner.stopAnimating()
				return
			}
			
			
			let parsedResult : AnyObject!
			
			do {
				parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
			}catch {
				
				parsedResult = nil
				print("Could not parse the data (Foursquare photo ) as JSON : \(data)")
				self.spinner.stopAnimating()
				return
			}
			
			
			guard let meta = parsedResult["meta"] as! NSDictionary?, stat = meta["code"] as? Int where stat == 200 else {
				print ("Google geocoding API returned an error = See error code in \(parsedResult)")
				self.spinner.stopAnimating()
				return
			}
			
			guard let response = parsedResult["response"] as? NSDictionary, photos = response["photos"] as? NSDictionary,
			let photoCount = photos["count"] as? Int where photoCount >= 1, let photoItems = photos["items"] as? NSArray
				else {
					print ("cannot find key / or count is zero / in \(parsedResult)")
					dispatch_async(dispatch_get_main_queue(), {
						self.spinner.stopAnimating()
					})
					return
			}
			
			let photoLimit = min(photoCount, 100)
			let randomPhoto = Int(arc4random_uniform(UInt32(photoLimit)))
			
			if let photo = photoItems[randomPhoto] as? NSDictionary {
				let prefix = photo["prefix"]!
				let suffix = photo["suffix"]!
				
				print(prefix, "original" , suffix)
				let photoURLString = (prefix as! String) + "width600" + (suffix as! String)
				let photoURL = NSURL(string:photoURLString)
				if let imageData = NSData(contentsOfURL: photoURL!) {
					dispatch_async(dispatch_get_main_queue(), {
						self.spinner.stopAnimating()
						self.restaurantImageView.image = UIImage(data: imageData)
						self.restaurantImageView.alpha = 0.5
						
					})
				} else {
					self.spinner.stopAnimating()
					print("Image does not exist at \(photoURL)")
				}
				
			}
			
			
			
		}
		
		task.resume()
		
	}
	
	
	// MARK: Helper methods
	
	func addKeyboardDismissRecognizer() {
		
		self.view.addGestureRecognizer(tapRecognizer!)
	}
	
	func removeKeyboardDismissRecognizer() {
		
		self.view.removeGestureRecognizer(tapRecognizer!)
	}
	
	
	func subscribeKeyboardNotifications() {
	
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
		
	
	}
	
	func unsubscribeKeyboardNotifications() {
	
		NSNotificationCenter.defaultCenter().removeObserver(self,name: UIKeyboardWillHideNotification, object:  nil)
	}
	
	func keyboardWillShow(notification: NSNotification) {
		if self.restaurantImageView.image != nil {
			self.restaurantName.alpha = 0.0
		}
		
		if self.view.frame.origin.y == 0.0  {
		
			self.view.frame.origin.y -= self.getKeyboardHeight(notification) / 1.2
		}
	
	}
	func keyboardWillHide(notification: NSNotification) {
		
		if self.restaurantImageView.image == nil {
			self.restaurantName.alpha = 1.0
		}
		
		if self.view.frame.origin.y != 0.0 {
			
			self.view.frame.origin.y += self.getKeyboardHeight(notification) / 1.2
		}
	
	}
	
	func getKeyboardHeight(notification: NSNotification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.CGRectValue().height
	}
	
	func handleSingleTap(recognizer: UITapGestureRecognizer) {
		self.view.endEditing(true)
	}

}

extension ViewController {
	func dismissAnyVisibleKeyboards()  {
	
		if locationTextField.isFirstResponder() || restaurantTextField.isFirstResponder() {
			self.view.endEditing(true)
		}
	}

}

