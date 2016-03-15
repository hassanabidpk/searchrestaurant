//
//  ViewController.swift
//  Search Restaurant
//
//  Created by NexStreamingCorp on 1/4/16.
//  Copyright © 2016 NexStreamingCorp. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire

class ViewController: UIViewController {
	
	
	let GOOGLE_API_KEY = "AIzaSyDfSn5O7yYTPHtBg4PC41ydWPw364h5riE"
	let GOOGLE_BASE_URL_HOST = "maps.googleapis.com"
    let API_BASE_URL = "https://searchrestaurant.pythonanywhere.com/api/v1"
	
	@IBOutlet weak var restaurantImageView: UIImageView!
	@IBOutlet weak var restaurantName: UILabel!
	
	@IBOutlet weak var locationTextField: UITextField!
	@IBOutlet weak var restaurantTextField: UITextField!
	
	@IBOutlet weak var restaurantAddress: UILabel!
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	@IBOutlet weak var restaurantCheckins: UILabel!
    @IBOutlet weak var showRestaurantsList: UIBarButtonItem!
	
	var tapRecognizer: UITapGestureRecognizer? = nil
	var placesClient: GMSPlacesClient?
	var locationManager: CLLocationManager!
	var latlngFromCurrLoc : String?
	var currentPlaceName : String?
    var placePicker : GMSPlacePicker?
	var restaurants = [Restaurant] ()
    var count: Int = 1
    
    
	
	@IBAction func searchRestaurant(sender: UIButton) {
		
		print("search restaurant")
		self.dismissAnyVisibleKeyboards()
        //TODO: handle case where two
		if !self.locationTextField.text!.isEmpty && !self.restaurantTextField.text!.isEmpty {
            self.showRestaurantsList.enabled = false
			self.restaurantName.text = "Searching .... "
			self.restaurantCheckins.text = ""
			self.restaurantAddress.text = ""
			self.spinner.startAnimating()
			if let currentPlaceName = currentPlaceName  {
				if currentPlaceName != self.locationTextField.text  {
					self.latlngFromCurrLoc = nil
					print("get place by searching")
				}
			}
			if let latlng = self.latlngFromCurrLoc {
                //TODO: handle this case
				print("search for same location : \(latlng)")
                let latlngArray = latlng.characters.split{$0 == ","}.map(String.init)
                self.getRestaurantsViaApi(latlngArray[0], lng: latlngArray[1])
			} else {
				let gURL = self.getURLForQuery()
				print(gURL)
				self.getLocationCordinates(gURL)
			}
		} else {
		
			self.restaurantName.text = "Enter both location and restaurant type!"
			self.restaurantCheckins.text = ""
			self.restaurantAddress.text = ""
		}
	
	
	}
	
	
	@IBAction func getCurrentLocation(sender: UIButton) {
		/* Use GoogleMaps API */
		print("getCurrentLocation ")
		if(!CLLocationManager.locationServicesEnabled()) {
			locationManager.requestWhenInUseAuthorization()
			return
		}
		placesClient?.currentPlaceWithCallback({
			(placeLikelihoodList: GMSPlaceLikelihoodList? , error: NSError?) -> Void in
			
			if let error = error  {
				print("Pick place error : \(error.localizedDescription)")
				return
			}
			
			self.locationTextField.text = "No Current Place"
			
			if let placeLikelihoodList = placeLikelihoodList {
				print("\(placeLikelihoodList)")
				let place = placeLikelihoodList.likelihoods.first?.place
				if let place = place {
					
					self.currentPlaceName = place.name
					self.locationTextField.text = place.name
					print("place : \(place.name)")
					var latlng: CLLocationCoordinate2D!
					latlng = place.coordinate
					print(latlng)
					self.latlngFromCurrLoc = "\(latlng.latitude),\(latlng.longitude)"
				
				}
			}
		})
		
	}
	
    @IBAction func pickPlace(sender: UIButton) {
        let center = CLLocationCoordinate2DMake(37.5667, 126.9667)
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        placePicker = GMSPlacePicker(config: config)
        
        placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                print("Place name \(place.name)")
                print("Place address \(place.formattedAddress)")
                print("Place attributions \(place.attributions)")
                self.currentPlaceName = place.name
                self.locationTextField.text = place.name
                print("place : \(place.name)")
                var latlng: CLLocationCoordinate2D!
                latlng = place.coordinate
                print(latlng)
                self.latlngFromCurrLoc = "\(latlng.latitude),\(latlng.longitude)"

            } else {
                print("No place selected")
            }
        })
        
    }
	override func viewDidLoad() {
		super.viewDidLoad()
	
		tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
		tapRecognizer?.numberOfTapsRequired = 1
		self.restaurantCheckins.text = ""
		self.restaurantAddress.text = ""
		self.spinner.stopAnimating()
		placesClient = GMSPlacesClient()
		locationManager = CLLocationManager()
		self.restaurantName.lineBreakMode = NSLineBreakMode.ByWordWrapping
		self.restaurantName.numberOfLines = 2
        
		
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		self.addKeyboardDismissRecognizer()
		self.subscribeKeyboardNotifications()
	}
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (self.restaurants.count != 0){
            let venueCount = restaurants.count
            let venueLimit = min(venueCount, 50)
            let randomRestaurantIndex = Int(arc4random_uniform(UInt32(venueLimit)))
            let randomRestaurant = restaurants[randomRestaurantIndex]
            self.setRandomRestaurant(randomRestaurant)
            self.showRestaurantsList.enabled = true
        } else {
            self.showRestaurantsList.enabled = false
        }
        
    }
	
	override func viewWillDisappear(animated: Bool) {
		
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
			

				self.getRestaurants("\(latitude)", lng:  "\(longitude)")
                self.getRestaurantsViaApi("\(latitude)", lng:  "\(longitude)")
			} else {
				print("latitude or longitude are nil")
				return
			}
			
		
		}
		
		task.resume()
		
		
	
	}
    
    func getRestaurantsViaApi(lat:String! , lng: String!) {
        restaurants.removeAll()
    let locationStr = self.locationTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let escapedRestaurantValue = "\(self.restaurantTextField.text!)"
        let params = ["location": locationStr,"rtype": escapedRestaurantValue]
        Alamofire.request(.GET, API_BASE_URL, parameters: params)
            .responseJSON { response in
//                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
                
                if let restaurants = response.result.value {
                    print("JSON: \(restaurants)")
                    if let error = restaurants["error"] {
                        print("No venue found | error :\(error)")
                        self.restaurantName.text = "Nothing found! Try again"
                        self.stopSpinner(nil)
                        return
                    }
                    let venueCount = restaurants.count
                    print(" count : \(restaurants.count)")
                    if (venueCount == 0) {
                        print("No venue found")
                        self.restaurantName.text = "Nothing found! Try again"
                        self.stopSpinner(nil)
                        return
                    }
                    let venueLimit = min(venueCount, 50)
                    let randomRestaurantIndex = Int(arc4random_uniform(UInt32(venueLimit)))
                    print(randomRestaurantIndex)
                    guard let results = restaurants as? NSArray
                        else {
                            print ("cannot find key location in \(restaurants)")
                            return
                    }
                    for r in results{
                        let photoURL = NSURL(string:r["photo_url"] as! String)
                        if let imageData = NSData(contentsOfURL: photoURL!) {
                                let image  = UIImage(data: imageData)
                       
                            let name = r["name"] as! String
                            let address = r["address"] as! String
                            let lat = r["latitude"] as! String
                            let lng = r["longitude"] as! String
                            let venue_id = r["venue_id"] as! String
                            let checkins = r["checkins"] as! UInt
                            let restaurant = Restaurant(name: name, photo: image, address: address, checkins: checkins, latitude: lat, longitude: lng, venue_id: venue_id)!
                            self.restaurants.append(restaurant)
                            
                            print("\(name) \(checkins) \(lat) \(venue_id)")
                        }
                        
                    }
                    let randomRestaurant = self.restaurants[randomRestaurantIndex]
                    self.setRandomRestaurant(randomRestaurant)
                   
                    self.saveRestaurants()
                    self.stopSpinner(nil)
                }
        }
    }
    
    func setRandomRestaurant(randomRestaurant: Restaurant) {
        dispatch_async(dispatch_get_main_queue(), {
            
            self.restaurantName.font = UIFont.systemFontOfSize(20.0)
            self.restaurantName.text = randomRestaurant.name
            self.restaurantCheckins.text = "Checkins : \(randomRestaurant.checkins)"
            self.restaurantAddress.lineBreakMode = NSLineBreakMode.ByWordWrapping
            self.restaurantAddress.numberOfLines = 0
            self.restaurantAddress.text = randomRestaurant.address
            self.restaurantImageView.image = randomRestaurant.photo
            print("randomrestaurant name : \(randomRestaurant.name)")
        })
    }
	
    
    func stopSpinner(error : String!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.spinner.stopAnimating()
            if let error = error {
                self.restaurantName.text = error
            }
        })
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
	
	
	func getRestaurants(lat:String! , lng: String!)  {
		
	}
	
    func getPhotoForRestaurant(id : String!, name: String!, address: String!,totalCount:Int)  {
		
		
	}
	
	// MARK: NSCoding
	
	func saveRestaurants() {
		deleteRestaurants()
        self.count = 0
		let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(restaurants, toFile: Restaurant.ArchiveURL.path!)

		self.spinner.stopAnimating()
		if !isSuccessfulSave {
			print("Failed to save restaurants...")
		} else {
            self.showRestaurantsList.enabled = true
			print("saved restaurants")
		}
	}
    
    func deleteRestaurants() {
        do {
        try  NSFileManager.defaultManager().removeItemAtPath(Restaurant.ArchiveURL.path!)
        } catch {
            print("couldn't delete restaurant")
        }
    
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
//        self.saveRestaurants()
        
    }

}

