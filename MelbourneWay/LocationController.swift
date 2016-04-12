//
//  LocationController.swift
//  MelbourneWay
//
//  Created by Chandan Singh on 5/04/2016.
//  Copyright © 2016 RMIT. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationController: UIViewController {
    
    //Mark: Properties
    
    @IBOutlet weak var currentField: UITextField!
    
    @IBOutlet weak var destinationField: UITextField!
    
    @IBOutlet var checkAddressButtons: [UIButton]!
    
    @IBOutlet weak var viewRouteButton: UIButton!
    
    
    
    let locationManager = CLLocationManager()

    var locationTuples: [(textField: UITextField!, mapItem: MKMapItem?)]!
    
    var locationsArray: [(textField: UITextField!, mapItem: MKMapItem?)] {
        var filtered = locationTuples.filter({ $0.mapItem != nil })
        filtered += [filtered.first!]
        return filtered
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAddressButtons.first?.layer.cornerRadius = 5
        checkAddressButtons.last?.layer.cornerRadius = 5
        viewRouteButton.layer.cornerRadius = 5
        
        
        locationTuples = [(currentField, nil), (destinationField, nil)]
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        //navigationController?.navigationBarHidden = true
    }
    
    
    //Mark: Actions
    
    // Address Entered
    @IBAction func checkAddressAction(sender: UIButton) {
        view.endEditing(true)
        
        let currentTextField = locationTuples[sender.tag-1].textField
        
        CLGeocoder().geocodeAddressString(currentTextField.text!,
            completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                if let placemarks = placemarks {
                    var addresses = [String]()
                    for placemark in placemarks {
                        addresses.append(self.formatAddressFromPlacemark(placemark))
                    }
                    self.showAddressTable(addresses, textField: currentTextField,
                        placemarks: placemarks, sender: sender)
                } else {
                    self.showAlert("Address not found.")
                }
        })
    }
    
    
    // Get Directions
    @IBAction func viewRoute(sender: AnyObject) {
        view.endEditing(true)
        performSegueWithIdentifier("viewMap", sender: self)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if (locationTuples[0].mapItem == nil) || (locationTuples[1].mapItem == nil) {
                showAlert("Please enter a valid starting point and destination.")
                return false
        } else {
            return true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let routeViewController = segue.destinationViewController as! UITabBarController
        let mapData = routeViewController.viewControllers?.first as! RouteViewController
        mapData.locationArray = locationsArray
    }
    
    
    func showAlert(alertString: String) {
        let alert = UIAlertController(title: nil, message: alertString, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK",
            style: .Cancel) { (alert) -> Void in
        }
        alert.addAction(okButton)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func formatAddressFromPlacemark(placemark: CLPlacemark) -> String {
        return (placemark.addressDictionary!["FormattedAddressLines"] as!
            [String]).joinWithSeparator(", ")
    }
    
    func showAddressTable(addresses: [String], textField: UITextField,
        placemarks: [CLPlacemark], sender: UIButton) {
            
            let addressTableView = DestinationTableView(frame: UIScreen.mainScreen().bounds, style: UITableViewStyle.Plain)
            addressTableView.addresses = addresses
            addressTableView.currentTextField = textField
            addressTableView.placemarkArray = placemarks
            addressTableView.mainViewController = self
            addressTableView.sender = sender
            addressTableView.delegate = addressTableView
            addressTableView.dataSource = addressTableView
            view.addSubview(addressTableView)
    }
    
}

extension LocationController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        checkAddressButtons.filter{$0.tag == textField.tag}.first!.selected = false
        locationTuples[textField.tag-1].mapItem = nil
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension LocationController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(locations.last!,
            completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                if let placemarks = placemarks {
                    let placemark = placemarks[0]
                    self.locationTuples[0].mapItem = MKMapItem(placemark:
                        MKPlacemark(coordinate: placemark.location!.coordinate,
                            addressDictionary: placemark.addressDictionary as! [String:AnyObject]?))
                    self.currentField.text = self.formatAddressFromPlacemark(placemark)
                    
                    self.checkAddressButtons.filter{$0.tag == 1}.first!.selected = true
                    
                    if (self.checkAddressButtons.first?.state == .Selected ){
                        self.checkAddressButtons.first?.backgroundColor = UIColor(red: 76.0/255.0, green: 175.0/255.0, blue: 80.0/255.0, alpha: 1.0)
                        self.checkAddressButtons.first?.setTitle("Checked", forState: .Selected)
                    } else {
                        self.checkAddressButtons.first?.backgroundColor = UIColor.orangeColor()
                    }
                }
        })
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
}
