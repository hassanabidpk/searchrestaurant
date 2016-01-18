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
	var restaurants = [Restaurant] ()
	
	@IBAction func cancelToRestaurantTableViewController(segue:UIStoryboardSegue) {
	}
 
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "dimisscontroller:")
		
		if let savedRestaurants = loadRestaurants() {
			restaurants += savedRestaurants
			print("restaurants found with size :", restaurants.count)
			
		} else {
			print("no restaurants found")
		}
		
		
	}
	
	func dimisscontroller(button: UIBarButtonSystemItem) {
		self.dismissViewControllerAnimated(false, completion: nil)
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return restaurants.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		// Table view cells are reused and should be dequeued using a cell identifier.
		let cellIdentifier = "RestaurantTableViewCell"
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! RestaurantTableViewCell
		
		// Fetches the appropriate restaurant for the data source layout.
		let restaurant = restaurants[indexPath.section]
		
		cell.restaurantName.text = restaurant.name
		cell.restaurantImage.image = restaurant.photo
		cell.restaurantAddress.text = restaurant.address
		
		return cell
	}
	
	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 1
	}
	
	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView()
		headerView.backgroundColor = UIColor.orangeColor()
		return headerView;
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		print(indexPath.section)
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return false
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		print("prepareForSegue")
	}
	
	
	func loadRestaurants() -> [Restaurant]? {
		return NSKeyedUnarchiver.unarchiveObjectWithFile(Restaurant.ArchiveURL.path!) as? [Restaurant]
	}
	


}
