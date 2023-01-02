//
//  MKMapView + .swift
//  IFood
//
//  Created by Артём on 02.01.2023.
//

import Foundation
import MapKit

extension MKMapView {
    func getCenterLocation() -> CLLocation {
        let longitude = centerCoordinate.longitude
        let latitude = centerCoordinate.latitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
