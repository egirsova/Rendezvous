//
//  MainViewController.swift
//  Rendezvous
//
//  Created by Liza Girsova on 12/3/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var addressLabel: UILabel!
    var currentLocation: CLLocation?
    
    var kNewRendezvousPoint = "newRendezvousPointNotification"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // First get user's location
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
            
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        let camera = GMSCameraPosition.cameraWithLatitude(0,
            longitude: 0, zoom: 1)
        mapView.camera = camera
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addRendezvousPoint:", name: kNewRendezvousPoint, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addRendezvousPoint(notification: NSNotification) {
        let userInfo:Dictionary<String,CLLocation> = notification.userInfo as! Dictionary<String,CLLocation>
        userInfo
        let targetLocation = userInfo["location"]
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(targetLocation!.coordinate.latitude, targetLocation!.coordinate.longitude)
        marker.title = "Target"
        marker.snippet = "Target"
        marker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        marker.map = mapView
    }
    
    @IBAction func logoutButtonPressed(sender: UIButton) {
        // First logout
        PFUser.logOutInBackground()
        
        // Switch to loginview
        let view = self.storyboard?.instantiateViewControllerWithIdentifier("loginView")
        self.showViewController(view! as UIViewController, sender: view)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        let latitude = location!.coordinate.latitude
        let longitude = location!.coordinate.longitude
        
        // Update map
        let camera = GMSCameraPosition.cameraWithLatitude(latitude,
            longitude: longitude, zoom: 18)
        mapView.camera = camera
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
        marker.title = "You Are Here"
        marker.snippet = "Your Location"
        marker.map = mapView
        
        CurrentUser.user.location = location!
        
        reverseGeocodeCoordinate(location!.coordinate)
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                let lines = address.lines as! [String]
                self.addressLabel.text = lines.joinWithSeparator("\n")
                
                UIView.animateWithDuration(0.25) {
                    self.mapView.layoutIfNeeded()
                }
            }
            
        }
    }
}
