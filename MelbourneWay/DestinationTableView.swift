//
//  DestinationTableView.swift
//  MelbourneWay
//
//  Created by Chandan Singh on 5/04/2016.
//  Copyright © 2016 RMIT. All rights reserved.
//


import UIKit
import MapKit

class DestinationTableView: UITableView {
    
    var mainViewController: LocationController!
    var addresses: [String]!
    var placemarkArray: [CLPlacemark]!
    var currentTextField: UITextField!
    var sender: UIButton!
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.registerClass(UITableViewCell.self, forCellReuseIdentifier: "AddressCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension DestinationTableView: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont(name: "HoeflerText-Black", size: 18)
        label.textAlignment = .Center
        label.text = "Did you mean..."
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor.orangeColor()
        
        return label
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if addresses.count > indexPath.row {
            currentTextField.text = addresses[indexPath.row]
            let mapItem = MKMapItem(placemark:
                MKPlacemark(coordinate: placemarkArray[indexPath.row].location!.coordinate,
                    addressDictionary: placemarkArray[indexPath.row].addressDictionary
                        as! [String:AnyObject]?))
            mainViewController.locationTuples[currentTextField.tag-1].mapItem = mapItem
            sender.selected = true
            if (sender.state == .Selected){
                sender.backgroundColor = UIColor(red: 76.0/255.0, green: 175.0/255.0, blue: 80.0/255.0, alpha: 1.0)
                sender.setTitle("Checked", forState: .Selected)

            } else {
                sender.backgroundColor = UIColor.orangeColor()
            }
        }
        removeFromSuperview()
    }
}

extension DestinationTableView: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AddressCell") as UITableViewCell!
        cell.textLabel?.numberOfLines = 3
        cell.textLabel?.font = UIFont(name: "HoeflerText-Regular", size: 11)
        
        if addresses.count > indexPath.row {
            cell.textLabel?.text = addresses[indexPath.row]
        } else {
            cell.textLabel?.text = "None of the above"
        }
        return cell
    }
}