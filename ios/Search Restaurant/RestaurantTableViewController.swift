//
//  RestaurantTableViewController.swift
//  Search_Restaurant
//
//  Created by NexStreamingCorp on 1/18/16.
//  Copyright © 2016 NexStreamingCorp. All rights reserved.
//

import UIKit

class RestaurantTableViewController: UITableViewController {

	// MARK: Properties
	var restaurants = [Restaurant]()

	@IBAction func cancelToRestaurantTableViewController(segue: UIStoryboardSegue) {
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
		                                                    target: self,
		                                                    action: #selector(dimisscontroller(_:)))

		if let savedRestaurants = loadRestaurants() {
			restaurants += savedRestaurants
			print("restaurants found with size :", restaurants.count)
		} else {
			print("no restaurants found")
		}
	}

	@objc func dimisscontroller(_ sender: Any) {
		self.dismiss(animated: false, completion: nil)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return restaurants.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "RestaurantTableViewCell"
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RestaurantTableViewCell

		let restaurant = restaurants[indexPath.section]
		cell.restaurantName.text = restaurant.name
		cell.restaurantImage.image = restaurant.photo
		cell.restaurantAddress.text = restaurant.address

		return cell
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 1
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView()
		headerView.backgroundColor = UIColor.orange
		return headerView
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print(indexPath.section)
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return false
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		print("prepareForSegue")
	}

	func loadRestaurants() -> [Restaurant]? {
		// Kept on the legacy keyed archiver to preserve the on-disk format
		// written by ViewController.saveRestaurants(). Deprecated but valid.
		return NSKeyedUnarchiver.unarchiveObject(withFile: Restaurant.archiveURL.path) as? [Restaurant]
	}
}
