//
//  mapViewController.swift
//  shareMap
//
//  Created by Likai Yan on 4/7/17.
//  Copyright © 2017 Likai Yan. All rights reserved.
//

import Foundation

import UIKit
import CoreLocation
import MapKit
import FirebaseAuth

// TODO: programmatically connect map to navigation controller to collectionview controller, which leads to detailed view of an entry.

class mapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var currentUser = FIRAuth.auth()?.currentUser?.email
    
    // init database to access the location.
    var myMapUser = mapUser();
    
    let locationManager = CLLocationManager();
    var coord = CLLocationCoordinate2D();
    // let userLocation = CLLocation();
    
    @IBAction func LogOutButton(_ sender: UIButton) {
        do {
            try FIRAuth.auth()?.signOut()
            self.presentHomePage()
        }
        catch {
            print("There was a problem logging out!")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        myMapUser = mapUser();
        super.viewWillAppear(false);
    }
    func presentHomePage () {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let welcomeVC: WelcomeViewController = storyboard.instantiateViewController(withIdentifier: "StartPage") as! WelcomeViewController
        self.present(welcomeVC, animated: true, completion: nil)
    }
    
    @IBAction func whereAmI(_ sender: UIButton) {
        mapView.setCenter(coord, animated: true)
        mapView.zoomToUserLocation();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        mapView.delegate = self
        mapView.showsUserLocation = false
        mapView.mapType = MKMapType(rawValue: 0)! // case standard
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 1)! // case follow

        locationManager.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        // print(CLLocationManager.locationServicesEnabled())

        /*
        var anView:MKAnnotationView = MKAnnotationView()
        anView.annotation = myHomePin
        anView.image = #imageLiteral(resourceName: "first")
        anView.canShowCallout = true
        anView.isEnabled = true
 */

    }
    
    // http://stackoverflow.com/questions/24467408/swift-add-mkannotationview-to-mkmapview
    // update current location
    // record the last MKAnnotation, and delete it upon refreshing!
    
    var lastAnnotation:MKAnnotation?
    var lastCLLoc:CLLocation?
    var delayConter = 3;
    // var decodedAddr = ""
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // added distance change -> Reverse Geo query if it does not change more than 10 m we ignore it
        // async trigger MKAnno re-rendering
        // quick fix is to put this at the beginning of the function.
        if let unwrappedLastLoc = lastCLLoc {
            let dist = unwrappedLastLoc.distance(from: locations.last!);
            // print(dist);
            if dist < 100 {
                return;
            }
        }
        // we know there is at least 1 element in the array!
        // userLocation = locations.last!
        // lat="38.63779096" lon="-90.3429794">
        coord = locations.last!.coordinate;

        let defaults = UserDefaults.standard
        defaults.set(coord.latitude, forKey: "latitude")
        defaults.set(coord.longitude, forKey: "longitude")
        
        //print("========================current position" + String(defaults.double(forKey: "latitude")))
        
//        let appD = UIApplication.shared.delegate as! AppDelegate;
//        appD.currentLocation.latitude = coord.latitude as Double
//        appD.currentLocation.long = coord.longitude as Double
  
        
        
        if lastAnnotation != nil{
            let myHomePin = MKPointAnnotation();
            myHomePin.coordinate = coord;
            myHomePin.title = lastAnnotation?.title!;
            myHomePin.subtitle = lastAnnotation?.subtitle!;
            mapView.addAnnotation(myHomePin)
            mapView.selectAnnotation(myHomePin, animated: false);
            mapView.removeAnnotation(lastAnnotation!)
            lastAnnotation = myHomePin;
        }
        let coordDisplay = "\(coord.latitude),\(coord.longitude)"
        
        // http://stackoverflow.com/questions/27495328/reverse-geocode-location-in-swift
        let geoCoder = CLGeocoder()
        
        //        if let unwrappedLastLoc = lastCLLoc {
        //            let dist = unwrappedLastLoc.distance(from: locations.last!);
        //            print(dist);
        //            if dist < 1000 {
        //                return;
        //            }
        //        }
        
        print ("hey i'm not returning");
        //if delayConter % 5 == 0 {
        if true{
            geoCoder.reverseGeocodeLocation(locations.last!, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                // print (placemarks);
                if (placemarks != nil) {
                    // print("p is not nil")
                    for p in placemarks! {
                        // iotDataManager.publishString(p.compactAddress!, onTopic: "address", qoS:.messageDeliveryAttemptedAtMostOnce)
                        if self.lastAnnotation != nil{
                            self.mapView.removeAnnotation(self.lastAnnotation!);
                        }

                        let myHome = locations.last!
                        let myHomePin = MKPointAnnotation()
                        myHomePin.subtitle = p.compactAddress! // to be changed to your reversed GeoCode
                        // print(p);
                        myHomePin.coordinate = myHome.coordinate;
                        myHomePin.title = "Your location"
                        
                        // TODO: optimize using addAnno([]);
                        self.mapView.removeAnnotations(self.mapView.annotations);
                        self.mapView.addAnnotation(myHomePin)
                        
                        // fetch surroundings;
                        var otherAnnotations = self.myMapUser.lookAround(location: myHome.coordinate);
                        for otherAnnotation in otherAnnotations{
                            self.mapView.addAnnotation(otherAnnotation);
                        }
                        // let MKPAArr = [myHomePin]
                        self.mapView.selectAnnotation(myHomePin, animated: false)
                        self.lastAnnotation = myHomePin;
                        self.lastCLLoc = myHome;
                        print ("lol new tag");
                    }
                }
                if (placemarks?.count)! > 0 {
                    //  print(placemarks![0].locality ?? "failed to fetch")
                }
                else {
                    // print("Problem with the data received from geocoder")
                }
            })
        }
        delayConter += 1;
    }
    
    // this sets the MKAV to display MKA
    // http://stackoverflow.com/questions/24467408/swift-add-mkannotationview-to-mkmapview
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
            //return nil so map draws default view for it (eg. blue dot)...
            return MKAnnotationView();
        }
        let reuseId = "test"
        let reuseId2 = "test2"
        var anView2 = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId2)
        if anView2 == nil {
            anView2 = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId2)
            
            anView2?.image = "😆".image();
            // perhaps use "UIImage" average color as a preview.
            // radius to define visible area. Freshness (updated time) to define the size.
            anView2?.canShowCallout = true
            // whole bubble as a clickable
            //https://github.com/koogawa/MKMapViewSample/blob/master/MKMapViewSample/ImageViewController.swift
            let rightButton: AnyObject! = UIButton(type: UIButtonType.detailDisclosure)
            anView2?.rightCalloutAccessoryView = rightButton as? UIView
        }
        else {
            //we are re-using a view, update its annotation reference...
            anView2?.annotation = annotation
        }
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            let tag = annotation.subtitle!!
            
            switch tag{
            case "food": anView?.image = "🍖".image()
            case "profile" : anView?.image = "👶".image()
            case "activity" : anView?.image = "⚽️".image()
            case "landscape": anView?.image = "🌎".image()
            default: anView?.image = "🍖".image()
            }
            // perhaps use "UIImage" average color as a preview.
            // radius to define visible area. Freshness (updated time) to define the size.
            anView?.canShowCallout = true
            // whole bubble as a clickable
            //https://github.com/koogawa/MKMapViewSample/blob/master/MKMapViewSample/ImageViewController.swift
            let rightButton: AnyObject! = UIButton(type: UIButtonType.detailDisclosure)
            anView?.rightCalloutAccessoryView = rightButton as? UIView
        }
        else {
            //we are re-using a view, update its annotation reference...
            anView?.annotation = annotation
        }
        // TODO: add support for different type of interests!
        
        if lastAnnotation != nil {
            if lastAnnotation!.coordinate.longitude == annotation.coordinate.longitude && lastAnnotation!.coordinate.latitude == annotation.coordinate.latitude {
                return anView2;
            }
        }
        
        return anView;
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            performSegue(withIdentifier: "collectionViewController", sender: self);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


//https://cocoacasts.com/forward-and-reverse-geocoding-with-clgeocoder-part-2/
extension CLPlacemark {
    
    var compactAddress: String? {
        if name != nil {
            // var result = name
            var result = ""
            if let street = thoroughfare {
                result += "\(street)"
            }
            
            if let city = locality {
                result += ", \(city)"
            }
            /*
             if let country = country {
             result += ", \(country)"
             }
             */
            return result
        }
        
        return nil
    }
    
}
//http://stackoverflow.com/questions/38809425/convert-apple-emoji-string-to-uiimage
extension String {
    func image() -> UIImage {
        let size = CGSize(width: 30, height: 35)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.clear.set();
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 30)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}

