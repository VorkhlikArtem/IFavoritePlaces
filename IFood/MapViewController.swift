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
    
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    var incomeSegueIdentifier = ""
    var placeCoordinate: CLLocationCoordinate2D?
    var directionsArray: [MKDirections] = []
    var previousLocation: CLLocation? {
        didSet {
            startTrackingUserLocation()
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
        checkLocationServices()
    }
    
    // MARK: - Buttons Actions
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func centerViewInUserLocation(_ sender: Any) {
        showUserLocation()
    }
    
    @IBAction func donePressed(_ sender: Any) {
        delegate?.getAddress(currentAddress.text)
        dismiss(animated: true)
    }
    
    @IBAction func getDirection(_ sender: Any) {
        getDirections()
    }
    
    
    // MARK: - Map View Setups
    
    private func setupMapView() {
        getDirectionButton.isHidden = true
        
        if incomeSegueIdentifier == "showPlace" {
            currentAddress.isHidden = true
            pinImageView.isHidden = true
            doneButton.isHidden = true
            getDirectionButton.isHidden = false
            
            setupPlacemark()
        }
    }
    
    private func resetMapView(withNew directions: MKDirections) {
        map.removeOverlays(map.overlays)
        directionsArray.append(directions)
        directionsArray.forEach {$0.cancel()}
        directionsArray.removeAll()
    }
    
    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            map.setRegion(region, animated: true)
        }
    }
    
    private func startTrackingUserLocation() {
        guard let previousLocation = previousLocation else {return}
        let center = map.getCenterLocation()
        guard center.distance(from: previousLocation) > 50 else {return}
        self.previousLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
        }
    }
    
    private func setupPlacemark() {
        guard let location = place.location else {return}
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error { print(error); return}
            guard let placemarks = placemarks else {return}
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.map.showAnnotations([annotation], animated: true)
            self.map.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
        } else {
            showAlert(title: "Location services are disabled", message: "To enable it go to Settings -> Privacy -> Location Services and Turn on")
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            showAlert(title: "Your location is not available", message: "To give permission Go to Settings -> IFood -> Location")
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            map.showsUserLocation = true
            if incomeSegueIdentifier == "showUserLocation" { showUserLocation() }
            break
  
        @unknown default:
            print("new case")
        }
    }
    
    private func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { response, error in
            if let error = error { print(error); return}
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "Direction is not available")
                return
            }
            
            for route in response.routes {
                self.map.addOverlay(route.polyline)
                self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance/1000)
                let timeInterval = route.expectedTravelTime
                
                print(distance)
                print(timeInterval)
            }
        }
        
    }
    
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else {return nil}
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        return request
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
                self.showUserLocation()
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
        checkLocationAuthorization()
    }
}
