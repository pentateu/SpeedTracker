//
//  ViewController.swift
//  SpeedTracker
//
//  Created by Rafael Almeida on 23/07/15.
//  Copyright (c) 2015 ISWE. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RunViewController: UIViewController, MovementTrackerDelegate, MKMapViewDelegate {

    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var maxSpeedLabel: UILabel!
    
    @IBOutlet weak var avgSpeedLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    let tracker = MovementTracker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView();
        
        tracker.delegate = self
        
        if(CLLocationManager.locationServicesEnabled()){
            statusLabel.text = "starting ..."
            tracker.start()
        }
        else{
            statusLabel.text = "Location services disabled ;-("
        }
    }
    
    func setupMapView(){
        self.mapView.delegate = self
    }
    
    func updateSpeedDisplay(tracker:MovementTracker, locationInfo:LocationInfo){
        maxSpeedLabel.text = "\(tracker.maxSpeed) km/h"
        avgSpeedLabel.text = "\(tracker.averageSpeed) km/h"
        speedLabel.text = "\(locationInfo.speed) km/h"
    }
    
    func calculateMapRegion(latitudeRange:MinMax, longitudeRange:MinMax) -> MKCoordinateRegion {
        let lat = (latitudeRange.min + latitudeRange.max) / 2
        let lng = (longitudeRange.min + longitudeRange.max) / 2
        let center = CLLocationCoordinate2DMake(lat, lng)
        
        let latitudeDelta = (latitudeRange.max - latitudeRange.min) * 1.1    // 10% padding
        let longitudeDelta = (longitudeRange.max - longitudeRange.min) * 1.1 // 10% padding
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        let region = MKCoordinateRegionMake(center, span)
        
        return region
    }
    
    func createPolyline() -> MKPolyline {
        var coordinates = [
            tracker.locations[tracker.locations.count - 2].location.coordinate,
            tracker.locations[tracker.locations.count - 1].location.coordinate
        ]
        return MKPolyline(coordinates: &coordinates , count: 2)
    }
    
    
    func updateMapDisplay(tracker:MovementTracker, locationInfo:LocationInfo){
        let mapRegion = calculateMapRegion(tracker.latitudeRange, longitudeRange: tracker.longitudeRange)
        self.mapView.region = mapRegion
        
        if tracker.locations.count > 1 {
            self.mapView.addOverlay(createPolyline())
        }
    }
    
    //MovementTrackerDelegate
    func locationAdded(tracker:MovementTracker, locationInfo:LocationInfo){
        
        updateSpeedDisplay(tracker, locationInfo: locationInfo)
        
        updateMapDisplay(tracker, locationInfo: locationInfo)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Map Delegate
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let polyLine = overlay as? MKPolyline  {
            let renderer = MKPolylineRenderer(polyline: polyLine)
            renderer.strokeColor = UIColor.blackColor()
            renderer.lineWidth = 3
            return renderer
        }
        return nil
    }
    
}

