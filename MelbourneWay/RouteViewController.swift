//
//  RouteViewController.swift
//  MelbourneWay
//
//  Created by Chandan Singh on 5/04/2016.
//  Copyright © 2016 RMIT. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RouteViewController: UIViewController {
    
    //Mark: Properties
    
    @IBOutlet weak var mapsView: MKMapView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    var locationArray: [(textField: UITextField!, mapItem: MKMapItem?)]!
    var activityIndicator: UIActivityIndicatorView?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        
        mapsView.showsUserLocation = true
        
        let ann = MKPointAnnotation()
        ann.coordinate = CLLocationCoordinate2D(latitude: self.mapsView.userLocation.coordinate.latitude, longitude: self.mapsView.userLocation.coordinate.longitude)
        self.mapsView.addAnnotation(ann)
        

        addActivityIndicator()
        calculateSegmentDirections(0, time: 0, routes: [])
    }
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: UIScreen.mainScreen().bounds)
        activityIndicator?.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator?.backgroundColor = view.backgroundColor
        activityIndicator?.startAnimating()
        view.addSubview(activityIndicator!)
    }
    
    func hideActivityIndicator() {
        if activityIndicator != nil {
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        self.tabBarController?.title = "Route"
        automaticallyAdjustsScrollViewInsets = false
    }
    
    func calculateSegmentDirections(index: Int, time: NSTimeInterval, routes: [MKRoute]) {
        let request: MKDirectionsRequest = MKDirectionsRequest()
        request.source = locationArray[index].mapItem
        request.destination = locationArray[index+1].mapItem
        
        request.requestsAlternateRoutes = true
        
        request.transportType = .Automobile
        
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler ({
            (response: MKDirectionsResponse?, error: NSError?) in
            if let routeResponse = response?.routes {
                let quickestRouteForSegment: MKRoute = routeResponse.sort({$0.expectedTravelTime < $1.expectedTravelTime})[0]
                
                var timeVar = time
                var routeVar = routes
                let distance = (routeResponse.first?.distance)! / 1000.0
                
                routeVar.append(quickestRouteForSegment)
                
                timeVar += quickestRouteForSegment.expectedTravelTime
                
                if index+2 < self.locationArray.count {
                    self.hideActivityIndicator()
                    self.calculateSegmentDirections(index+1, time: timeVar, routes: routeVar)
                    self.showRoute(routeVar, distance: distance)
                } else {
                    
                }
                
            } else if let _ = error {
                let alert = UIAlertController(title: nil,
                    message: "Direction not available.", preferredStyle: .Alert)
                let okButton = UIAlertAction(title: "OK",
                    style: .Cancel) { (alert) -> Void in
                        self.navigationController?.popViewControllerAnimated(true)
                }
                alert.addAction(okButton)
                self.presentViewController(alert, animated: true,
                    completion: nil)
            }
        })
    }
    
    func showRoute(routes: [MKRoute], distance: CLLocationDistance) {
        for i in 0..<routes.count {
            plotPolyline(routes[i])
        }
        printDistanceToLabel(distance)
    }
    
    func printDistanceToLabel(distance: CLLocationDistance){
        let distanceString = distance.description
        distanceLabel.text = "Distance :  \(distanceString) Km's."
    }
    
    
    func plotPolyline(route: MKRoute) {
        
        mapsView.addOverlay(route.polyline)
        
        if mapsView.overlays.count == 1 {
            mapsView.setVisibleMapRect(route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                animated: false)
        }
            
        else {
            let polylineBoundingRect =  MKMapRectUnion(mapsView.visibleMapRect,
                route.polyline.boundingMapRect)
            mapsView.setVisibleMapRect(polylineBoundingRect,
                edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                animated: false)
        }
    }
}

extension RouteViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView,
        rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
            
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            if (overlay is MKPolyline) {
                if mapView.overlays.count == 1 {
                    polylineRenderer.strokeColor =
                        UIColor(red: 1.0/255.0, green: 144.0/255.0, blue: 202.0/255.0, alpha: 0.75)
                } else if mapView.overlays.count == 2 {
                    polylineRenderer.strokeColor =
                        UIColor.greenColor().colorWithAlphaComponent(0.75)
                } else if mapView.overlays.count == 3 {
                    polylineRenderer.strokeColor =
                        UIColor.redColor().colorWithAlphaComponent(0.75)
                }
                polylineRenderer.lineWidth = 2
            }
            return polylineRenderer
    }
}
    
    

