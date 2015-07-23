//
//  MovementTracker.swift
//  SpeedTracker
//
//  Created by Rafael Almeida on 23/07/15.
//  Copyright (c) 2015 ISWE. All rights reserved.
//

import Foundation
import CoreLocation

class LocationInfo {
    let speed:Double
    let distance:Double
    let location:CLLocation
    
    init(speed:Double, distance:Double, location:CLLocation){
        self.speed = speed
        self.distance = distance
        self.location = location
    }
    
}

protocol MovementTrackerDelegate {
    
    func locationAdded(tracker:MovementTracker, locationInfo:LocationInfo);
    
}

class MinMax{
    var min:Double = Double.infinity
    var max:Double = Double.infinity * -1
    
    func update(newValue:Double){
        min = min < newValue ? min : newValue
        max = max > newValue ? max : newValue
    }
}

class MovementTracker: NSObject, CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager?
    
    var locations = [LocationInfo]()
    
    var totalDistance:Double = 0
    
    var maxSpeed:Double = 0
    var averageSpeed:Double = 0
    
    let longitudeRange = MinMax()
    let latitudeRange = MinMax()
    let altitudeRange = MinMax()
    
    var delegate:MovementTrackerDelegate?
    
    func setupLocationManager(){
        if(self.locationManager == nil){
            self.locationManager = CLLocationManager()
        }
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.distanceFilter = 10
    }
    
    func start(){
        setupLocationManager()
        self.locationManager?.startUpdatingLocation()
    }
    
    func increaseTotalDistanceBy(distance:Double){
        self.totalDistance += distance
    }
    
    func addLocationInfo(locationInfo:LocationInfo){
        self.locations.append(locationInfo)
    }
    
    func notifyLocationInfoAdded(location:CLLocation) -> CLLocation {
        if let delegateInstance = delegate {
            delegateInstance.locationAdded(self, locationInfo: locations.last!)
        }
        return location
    }
    
    func getLastKnownLocation() -> CLLocation? {
        return self.locations.count > 0 ? self.locations.last?.location:nil
    }
    
    func saveMaxSpeed(distance:Double, speed:Double,  location:CLLocation) -> (Double, Double, CLLocation) {
        self.maxSpeed = speed > self.maxSpeed ? speed : self.maxSpeed;
        return (distance, speed, location)
    }
    
    func saveLocationRange(location:CLLocation) -> CLLocation {
        self.latitudeRange.update(location.coordinate.latitude)
        self.longitudeRange.update(location.coordinate.longitude)
        self.altitudeRange.update(location.altitude)
        return location
    }
    
    /*
    *  locationManager:didUpdateLocations:
    *
    *  Discussion:
    *    Invoked when new locations are available.  Required for delivery of
    *    deferred locations.  If implemented, updates will
    *    not be delivered to locationManager:didUpdateToLocation:fromLocation:
    *
    *    locations is an array of CLLocation objects in chronological order.
    */
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        locations
            .filter(acurateItem >>> asLocation)
            .map(
                notifyLocationInfoAdded >>>
                saveLocationRange >>>
                saveDistanceAndSpeed >>>
                saveMaxSpeed >>>
                calcSpeed >>>
                increaseTotalDistance >>>
                calcDistance >>>
                asLocation)
    }
    
    func increaseTotalDistance(distance:Double, location:CLLocation) -> (Double, CLLocation) {
        increaseTotalDistanceBy(distance)
        return (distance, location)
    }
    
    func saveDistanceAndSpeed(distance:Double, speed:Double, location:CLLocation) -> CLLocation {
        addLocationInfo(LocationInfo(speed: speed, distance: distance, location: location))
        return location
    }
    
    func calcSpeed(distance:Double, location:CLLocation) -> (Double, Double, CLLocation) {
        if let previousLocation = getLastKnownLocation() {
            let time = location.timestamp.timeIntervalSinceDate(previousLocation.timestamp)
            let speed = distance / time
            return (distance, speed, location)
        }
        return (distance, 0.0, location)
    }
    
    func calcDistance(location:CLLocation) -> (Double, CLLocation){
        if let previousLocation = getLastKnownLocation() {
            return (location.distanceFromLocation(previousLocation), location)
        }
        return (0.0, location)
    }
    
    func asLocation(anyObject:AnyObject) -> CLLocation {
        return anyObject as! CLLocation
    }
    
    func acurateItem(location:CLLocation) -> Bool {
        return location.horizontalAccuracy <= 10
    }
    
}