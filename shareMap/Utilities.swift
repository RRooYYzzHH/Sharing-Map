//
//  Utilities.swift
//  shareMap
//
//  Created by RoYzH on 4/24/17.
//  Copyright © 2017 Likai Yan. All rights reserved.
//

import UIKit
import MapKit

// ref https://www.raywenderlich.com/136165/core-location-geofencing-tutorial

extension UIViewController {
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension MKMapView {
    func zoomToUserLocation() {
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000)
        setRegion(region, animated: true)
    }
}
