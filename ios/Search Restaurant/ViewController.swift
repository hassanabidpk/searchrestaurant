//
//  ViewController.swift
//  Search Restaurant
//
//  Created by NexStreamingCorp on 1/4/16.
//  Copyright © 2016 NexStreamingCorp. All rights reserved.
//
//  Modernized from Swift 2 to Swift 5. The Google Places "current
//  location" / "pick place" features were removed: they depended on
//  GMSPlacePicker / the old GMSPlacesClient API, which Google removed
//  and redesigned into a separate paid SDK. The core flow (type a
//  location + type, geocode, fetch restaurants) does not need Maps.
//

import UIKit

class ViewController: UIViewController {

	let GOOGLE_API_KEY = "GOOGLE_API_KEY"
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

	var tapRecognizer: UITapGestureRecognizer?
	var latlngFromCurrLoc: String?
	var currentPlaceName: String?
	var restaurants = [Restaurant]()
	var count: Int = 1

	@IBAction func searchRestaurant(_ sender: UIButton) {
		print("search restaurant")
		self.dismissAnyVisibleKeyboards()
		if !self.locationTextField.text!.isEmpty && !self.restaurantTextField.text!.isEmpty {
			self.showRestaurantsList.isEnabled = false
			self.restaurantName.text = "Searching .... "
			self.restaurantCheckins.text = ""
			self.restaurantAddress.text = ""
			self.spinner.startAnimating()
			if let currentPlaceName = currentPlaceName {
				if currentPlaceName != self.locationTextField.text {
					self.latlngFromCurrLoc = nil
					print("get place by searching")
				}
			}
			if let latlng = self.latlngFromCurrLoc {
				print("search for same location : \(latlng)")
				let latlngArray = latlng.split(separator: ",").map(String.init)
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

	@IBAction func getCurrentLocation(_ sender: UIButton) {
		// Removed during modernization: depended on GMSPlacesClient
		// currentPlace API. Enter the location manually instead.
		showPlacesUnavailableAlert()
	}

	@IBAction func pickPlace(_ sender: UIButton) {
		// Removed during modernization: GMSPlacePicker was removed from
		// the Google Places SDK. Enter the location manually instead.
		showPlacesUnavailableAlert()
	}

	private func showPlacesUnavailableAlert() {
		let alert = UIAlertController(
			title: "Enter location manually",
			message: "Google Places lookup was removed when this app was modernized. Type a location in the text field and tap Search.",
			preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
		tapRecognizer?.numberOfTapsRequired = 1
		self.restaurantCheckins.text = ""
		self.restaurantAddress.text = ""
		self.spinner.stopAnimating()
		self.restaurantName.lineBreakMode = .byWordWrapping
		self.restaurantName.numberOfLines = 2
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.addKeyboardDismissRecognizer()
		self.subscribeKeyboardNotifications()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if self.restaurants.count != 0 {
			let venueCount = restaurants.count
			let venueLimit = min(venueCount, 50)
			let randomRestaurantIndex = Int.random(in: 0..<venueLimit)
			let randomRestaurant = restaurants[randomRestaurantIndex]
			self.setRandomRestaurant(randomRestaurant)
			self.showRestaurantsList.isEnabled = true
		} else {
			self.showRestaurantsList.isEnabled = false
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.removeKeyboardDismissRecognizer()
		self.unsubscribeKeyboardNotifications()
	}

	func getURLForQuery() -> URL {
		var googleComponents = URLComponents()
		googleComponents.scheme = "https"
		googleComponents.host = GOOGLE_BASE_URL_HOST
		googleComponents.path = "/maps/api/geocode/json"
		let queryString = self.locationTextField.text!.replacingOccurrences(of: " ", with: "+")
		googleComponents.queryItems = [
			URLQueryItem(name: "address", value: queryString),
			URLQueryItem(name: "key", value: GOOGLE_API_KEY)
		]
		return googleComponents.url!
	}

	func getLocationCordinates(_ url: URL) {
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			guard error == nil else {
				print("There is error in Google Geo-coding api request")
				return
			}
			guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
			      statusCode >= 200 && statusCode <= 299 else {
				print("Your Google geocoding request returned an Invalid response!")
				return
			}
			guard let data = data else {
				print("No data was returned by the request")
				return
			}

			let parsedResult: Any
			do {
				parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
			} catch {
				print("Could not parse the data as JSON")
				return
			}

			guard let json = parsedResult as? [String: Any] else {
				print("Unexpected geocoding response")
				return
			}
			guard let stat = json["status"] as? String, stat == "OK" else {
				print("Google geocoding API returned an error: \(json)")
				self.stopSpinner((json["status"] as? String) ?? "Error")
				return
			}
			guard let results = json["results"] as? [[String: Any]],
			      let first = results.first,
			      let geometry = first["geometry"] as? [String: Any],
			      let location = geometry["location"] as? [String: Any] else {
				print("cannot find key location in \(json)")
				return
			}

			if let latitude = location["lat"], let longitude = location["lng"] {
				self.getRestaurantsViaApi("\(latitude)", lng: "\(longitude)")
			} else {
				print("latitude or longitude are nil")
			}
		}
		task.resume()
	}

	func getRestaurantsViaApi(_ lat: String, lng: String) {
		restaurants.removeAll()
		let locationStr = self.locationTextField.text!.replacingOccurrences(of: " ", with: "+")
		let escapedRestaurantValue = "\(self.restaurantTextField.text!)"

		var components = URLComponents(string: API_BASE_URL)!
		components.queryItems = [
			URLQueryItem(name: "location", value: locationStr),
			URLQueryItem(name: "rtype", value: escapedRestaurantValue)
		]
		guard let url = components.url else { return }

		let task = URLSession.shared.dataTask(with: url) { data, _, error in
			guard error == nil, let data = data else {
				print("Restaurant API request failed: \(error?.localizedDescription ?? "no data")")
				self.stopSpinner(nil)
				return
			}

			let parsed = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)

			if let dict = parsed as? [String: Any], let err = dict["error"] {
				print("No venue found | error :\(err)")
				DispatchQueue.main.async { self.restaurantName.text = "Nothing found! Try again" }
				self.stopSpinner(nil)
				return
			}

			guard let results = parsed as? [[String: Any]], !results.isEmpty else {
				print("No venue found")
				DispatchQueue.main.async { self.restaurantName.text = "Nothing found! Try again" }
				self.stopSpinner(nil)
				return
			}

			for r in results {
				guard let urlString = r["photo_url"] as? String,
				      let photoURL = URL(string: urlString),
				      let imageData = try? Data(contentsOf: photoURL),
				      let image = UIImage(data: imageData),
				      let name = r["name"] as? String,
				      let address = r["address"] as? String else {
					continue
				}
				let latStr = "\(r["latitude"] ?? "")"
				let lngStr = "\(r["longitude"] ?? "")"
				let venueId = "\(r["venue_id"] ?? "")"
				let checkins = (r["checkins"] as? NSNumber)?.uintValue ?? 0
				if let restaurant = Restaurant(name: name, photo: image, address: address,
				                               checkins: checkins, latitude: latStr,
				                               longitude: lngStr, venue_id: venueId) {
					self.restaurants.append(restaurant)
					print("\(name) \(checkins) \(latStr) \(venueId)")
				}
			}

			guard !self.restaurants.isEmpty else {
				DispatchQueue.main.async { self.restaurantName.text = "Nothing found! Try again" }
				self.stopSpinner(nil)
				return
			}

			let venueLimit = min(self.restaurants.count, 50)
			let randomRestaurantIndex = Int.random(in: 0..<venueLimit)
			let randomRestaurant = self.restaurants[randomRestaurantIndex]
			self.setRandomRestaurant(randomRestaurant)
			self.saveRestaurants()
			self.stopSpinner(nil)
		}
		task.resume()
	}

	func setRandomRestaurant(_ randomRestaurant: Restaurant) {
		DispatchQueue.main.async {
			self.restaurantName.font = UIFont.systemFont(ofSize: 20.0)
			self.restaurantName.text = randomRestaurant.name
			self.restaurantCheckins.text = "Checkins : \(randomRestaurant.checkins)"
			self.restaurantAddress.lineBreakMode = .byWordWrapping
			self.restaurantAddress.numberOfLines = 0
			self.restaurantAddress.text = randomRestaurant.address
			self.restaurantImageView.image = randomRestaurant.photo
			print("randomrestaurant name : \(randomRestaurant.name)")
		}
	}

	func stopSpinner(_ error: String?) {
		DispatchQueue.main.async {
			self.spinner.stopAnimating()
			if let error = error {
				self.restaurantName.text = error
			}
		}
	}

	// MARK: Helper methods

	func addKeyboardDismissRecognizer() {
		self.view.addGestureRecognizer(tapRecognizer!)
	}

	func removeKeyboardDismissRecognizer() {
		self.view.removeGestureRecognizer(tapRecognizer!)
	}

	func subscribeKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
		                                       name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
		                                       name: UIResponder.keyboardWillHideNotification, object: nil)
	}

	func unsubscribeKeyboardNotifications() {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}

	@objc func keyboardWillShow(_ notification: Notification) {
		if self.restaurantImageView.image != nil {
			self.restaurantName.alpha = 0.0
		}
		if self.view.frame.origin.y == 0.0 {
			self.view.frame.origin.y -= self.getKeyboardHeight(notification) / 1.2
		}
	}

	@objc func keyboardWillHide(_ notification: Notification) {
		if self.restaurantImageView.image == nil {
			self.restaurantName.alpha = 1.0
		}
		if self.view.frame.origin.y != 0.0 {
			self.view.frame.origin.y += self.getKeyboardHeight(notification) / 1.2
		}
	}

	func getKeyboardHeight(_ notification: Notification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
		return keyboardSize.cgRectValue.height
	}

	@objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
		self.view.endEditing(true)
	}
}

extension ViewController {
	func dismissAnyVisibleKeyboards() {
		if locationTextField.isFirstResponder || restaurantTextField.isFirstResponder {
			self.view.endEditing(true)
		}
	}

	// MARK: NSCoding

	func saveRestaurants() {
		deleteRestaurants()
		self.count = 0
		// Deprecated keyed-archiver API kept to preserve the on-disk
		// format read by RestaurantTableViewController.loadRestaurants().
		let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(restaurants, toFile: Restaurant.archiveURL.path)
		DispatchQueue.main.async { self.spinner.stopAnimating() }
		if !isSuccessfulSave {
			print("Failed to save restaurants...")
		} else {
			DispatchQueue.main.async { self.showRestaurantsList.isEnabled = true }
			print("saved restaurants")
		}
	}

	func deleteRestaurants() {
		do {
			try FileManager.default.removeItem(atPath: Restaurant.archiveURL.path)
		} catch {
			print("couldn't delete restaurant")
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	}
}
