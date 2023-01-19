//
//  MapViewController.swift
//  IFood
//
//  Created by Артём on 30.12.2022.
//

import UIKit
import CoreLocation
import MapKit

protocol MapViewControllerDelegate: AnyObject {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIdentifier = ""
  
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(
                for: map ,
                   and: previousLocation) { currentLocation in
                       self.previousLocation = currentLocation
                       
                       DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                           self.mapManager.showUserLocation(mapView: self.map)
                       }
                   }
        }
    }
    
    weak var delegate: MapViewControllerDelegate?
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var currentAddress: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var getDirectionButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentAddress.text = ""
        map.delegate = self
        setupMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapManager.checkLocationServices(mapView: map, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
    }
    
    // MARK: - Buttons Actions
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func centerViewInUserLocation(_ sender: Any) {
        mapManager.showUserLocation(mapView: map)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        delegate?.getAddress(currentAddress.text)
        dismiss(animated: true)
    }
    
    @IBAction func getDirection(_ sender: Any) {
        mapManager.getDirections(for: map) { location in
            self.previousLocation = location
        }
    }
    
    // MARK: - Map View Setups
    
    private func setupMapView() {
        getDirectionButton.isHidden = true
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlacemark(place: place, map: map)
            currentAddress.isHidden = true
            pinImageView.isHidden = true
            doneButton.isHidden = true
            getDirectionButton.isHidden = false
        }
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {return nil}
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.getCenterLocation()
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.map)
            }
        }
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placemarks = placemarks else {return}
            let placemark = placemarks.first
            
            let street = placemark?.thoroughfare
            let building = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if let street = street, let building = building {
                    self.currentAddress.text = "\(street), \(building)"
                } else if let street = street {
                    self.currentAddress.text = "\(street)"
                } else {
                    self.currentAddress.text = ""
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAuthorization(mapView: map, segueIdentifier: incomeSegueIdentifier)
    }
}
