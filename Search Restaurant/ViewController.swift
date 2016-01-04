//
//  ViewController.swift
//  Search Restaurant
//
//  Created by NexStreamingCorp on 1/4/16.
//  Copyright © 2016 NexStreamingCorp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	let GOOGLE_API_KEY = "AIzaSyCsyy2d-DIZucnnpJl5SKPST8dvV_6n_Ok"
	let FOURSQUARE_CLIENT_ID = "URC5H2RL1RHRTXAW3N30JBRBQGOUZQ2MMSSPSEPQVVXXDDQE"
	let FOURSQUARE_CLIENT_SECRET = "25SAH5QCTNA2J2O24CJ2I1DHUXMUPOVG2P2DZAKEP3GKI2ER"
	let GOOGLE_BASE_URL_HOST = "maps.googleapis.com"
	let FOURSQUARE_BASE_URL_HOST = "api.foursquare.com"
	
	

	
	@IBOutlet weak var restaurantImageView: UIImageView!
	@IBOutlet weak var restaurantName: UILabel!
	
	@IBOutlet weak var locationTextField: UITextField!
	@IBOutlet weak var restaurantTextField: UITextField!
	
	var tapRecognizer: UITapGestureRecognizer? = nil
	
	@IBAction func searchRestaurant(sender: UIButton) {
		
		print("search restaurant")
		self.restaurantName.text = "Searching .... "
		
		self.dismissAnyVisibleKeyboards()
		let gURL = self.getURLForQuery()
		print(gURL)
	
		self.getLocationCordinates(gURL)
	
	
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	
		tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
		tapRecognizer?.numberOfTapsRequired = 1
		
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
		
		let addressItem = NSURLQueryItem(name: "address", value: "Seoul,+Korea")
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
			
			print(parsedResult)
			
			guard let stat = parsedResult["status"] as? String where stat == "OK" else {
				print ("Google geocoding API returned an error = See error code in \(parsedResult)")
				return
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

