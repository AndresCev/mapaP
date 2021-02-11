//
//  ViewController.swift
//  mapaP
//
//  Created by Apps2m on 27/01/2021.
//  Copyright © 2021 Apps2m. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var mapa: MKMapView!
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapa.showsUserLocation = true
        self.mapa.delegate = self
        self.locationManager.requestAlwaysAuthorization()
      
        mapa.setUserTrackingMode(.followWithHeading, animated: true)
        self.checkLocationAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        locationManager.startUpdatingLocation()
        
        locationManager.distanceFilter = 100
        
        let geoFenceRegion:CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(40.4167, -3.70325), radius: 100, identifier: "Boise")
        
        locationManager.startMonitoring(for: geoFenceRegion)
     
          // https://www.adictosaltrabajo.com/2017/08/16/geofences-en-ios-swift/
          //https://stackoverflow.com/questions/55985353/why-does-user-location-in-mkmapview-shows-latitude-0-0-and-longitude-0-0
          let punto = MKPointAnnotation()
          //madrid
          punto.coordinate = CLLocationCoordinate2D(latitude: 40.4167, longitude: -3.70325 )
          mapa.addAnnotation(punto)
         
          let coordenadasCirculo = CLLocationCoordinate2D(latitude: 40.4167, longitude: -3.70325)
          let radio = CLLocationDistance(1000)
          
          showCircle(coordinate: coordenadasCirculo, radius: radio)
          
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        // coordenadas del usuario
        let sourceLocation = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        let destinationLocation = CLLocationCoordinate2D(latitude: 40.4207500 , longitude: -3.7517500)
        
        createPath(sourceLocation: sourceLocation, destinationLocation: destinationLocation)
        
    }
    //entrar en la zona
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered: \(region.identifier)")
        
    }
    //salir de la zona
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited: \(region.identifier)")
    }
    
    
    
    func showCircle(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance){
         let circle = MKCircle(center: coordinate, radius: radius)
         mapa.addOverlay(circle)

     }
    
     
    
     func createPath(sourceLocation : CLLocationCoordinate2D, destinationLocation : CLLocationCoordinate2D) {
             let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
             let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
             let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
             let destinationItem = MKMapItem(placemark: destinationPlaceMark)
             let destinationAnotation = MKPointAnnotation()
             destinationAnotation.title = "Gurugram"
             if let location = destinationPlaceMark.location {
                 destinationAnotation.coordinate = location.coordinate
             }

             self.mapa.showAnnotations([ destinationAnotation], animated: true)

             let directionRequest = MKDirections.Request()
             directionRequest.source = sourceMapItem
             directionRequest.destination = destinationItem
             directionRequest.transportType = .walking

             let direction = MKDirections(request: directionRequest)


             direction.calculate { (response, error) in
                 guard let response = response else {
                     if let error = error {
                         print("ERROR FOUND : \(error.localizedDescription)")
                     }
                     return
                 }

                 let route = response.routes[0]
                 self.mapa.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)

                 let rect = route.polyline.boundingMapRect

                 self.mapa.setRegion(MKCoordinateRegion(rect), animated: true)

           }
         }
   func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
           
      
       if overlay is MKPolyline{
           
           let rendere = MKPolylineRenderer(overlay: overlay )
                  rendere.lineWidth = 3
                  rendere.strokeColor = .systemRed

                  return rendere
           
       }
    if overlay is MKCircle{
              
              let circleRenderer = MKCircleRenderer(overlay: overlay)
              circleRenderer.fillColor = .blue
              circleRenderer.alpha = 0.1

              return circleRenderer
              
          }
                  
      
               return nil
   }
    
    func checkLocationAuthorization(authorizationStatus: CLAuthorizationStatus? = nil) {
        switch (authorizationStatus ?? CLLocationManager.authorizationStatus()) {
        case .authorizedAlways, .authorizedWhenInUse:
            mapa.showsUserLocation = true
        case .notDetermined:
            if locationManager == nil {
                locationManager = CLLocationManager()
                locationManager.delegate = self
            }
            locationManager.requestWhenInUseAuthorization()
        default:
            print("Location Servies: Denied / Restricted")
        }
    }
    func setupLocationManager() {
               locationManager.delegate = self
               locationManager.desiredAccuracy = kCLLocationAccuracyBest
           }
           
           
           func centerViewOnUserLocation() {
               if let location = locationManager.location?.coordinate {
                  
               }
           }
           
           
           func checkLocationServices() {
               if CLLocationManager.locationServicesEnabled() {
                   setupLocationManager()
                   checkLocationAuthorization()
               } else {
                   // Show alert letting the user know they have to turn this on.
               }
           }
           
           
           func checkLocationAuthorization() {
               switch CLLocationManager.authorizationStatus() {
               case .authorizedWhenInUse:
                   mapa.showsUserLocation = true
                   centerViewOnUserLocation()
                   locationManager.startUpdatingLocation()
                   break
               case .denied:
                   // Show alert instructing them how to turn on permissions
                   break
               case .notDetermined:
                   locationManager.requestWhenInUseAuthorization()
               case .restricted:
                   // Show an alert letting them know what's up
                   break
               case .authorizedAlways:
                   break
               }
           }
    
    
}
extension ViewController: MKMapViewDelegate, CLLocationManagerDelegate {

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.checkLocationAuthorization(authorizationStatus: status)
        
    }

}


