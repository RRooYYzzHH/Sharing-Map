//
//  mapUsersModel.swift
//  shareMap
//
//  Created by Likai Yan on 4/19/17.
//  Copyright © 2017 Likai Yan. All rights reserved.
//

import Foundation
import MapKit
import SQLite
import FirebaseAuth

class rtData{
    var noteid : Int;
    var latitude : Double;
    var longtitude : Double;
    var tag : String;
    
    init(noteid : Int, latitude : Double,longtitude : Double,tag : String){
        self.noteid = noteid
        self.latitude = latitude
        self.longtitude = longtitude
        self.tag = tag
    }
}
class mapUser{
    // this class identifies the user's locaiton, and attempt to generate
    // a range that displays other users around this user.
    var currentUser = FIRAuth.auth()?.currentUser?.email
    var allReturn : [rtData] = []
    static var sharedInstance = DBUtil()
    var db:Connection?
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    let notes = Table("Note")
    let noteId = Expression<Int64>("noteId")
    let userForNote = Expression<String>("user")
    let locationIdForNote = Expression<Int64>("locationId")
    let tag = Expression<String>("tag")
    let isPrivate = Expression<Bool>("isPrivate")
    
    let location = Table("Location")
    let locationId = Expression<Int64>("locationId")
    let longitude = Expression<Double>("longitude")
    let latitude = Expression<Double>("latitude")
    
    init(){
        
        do{
            db = try Connection("\(path)/shareMap.sqlite")
            let query = notes.select(noteId,locationIdForNote,tag)
                .filter(userForNote != currentUser!)
            
            let allNotes = Array(try (db?.prepare(query))!)
            for note in allNotes{
                let subquery = location.select(latitude,longitude)
                    .filter(locationId  == note[locationIdForNote])
                let all = Array(try (db?.prepare(subquery))!)
                var lati = 0.0
                var long = 0.0
                
                for item in all{
                    lati = item[latitude]
                    long = item[longitude]
                }
                
                let newNote = rtData(noteid: Int(note[noteId]),latitude: lati,longtitude: long,tag: note[tag])
                allReturn.append(newNote)
            }
            
        }
        catch{
            print(error)
        }
        
    }
    
    //TODO: calculate the distance among notes and then generate the annotation
    
    func lookAround(location:CLLocationCoordinate2D)->[MKPointAnnotation]{
        // sample data, replce with data returned from sqlite
                let annotation1 = MKPointAnnotation()
                let coordinate = CLLocationCoordinate2DMake(38.63779096,-90.3429794)
                annotation1.coordinate = coordinate;
                annotation1.title = "Nice food"
                annotation1.subtitle = "Best fujita chicken in the Clayton!"
        
                let annotation2 = MKPointAnnotation()
                let coordinate2 = CLLocationCoordinate2DMake(38.63779096,-90.3343963)
                annotation2.coordinate = coordinate2;
                annotation2.title = "great BBQ"
                annotation2.subtitle = "The smoky pork is insanely good"
        
        // select close points.
        var locationArr : [MKPointAnnotation] = []
        for data in allReturn{
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2DMake(data.latitude,data.longtitude)
            annotation.coordinate = coordinate;
            annotation.title = String(data.noteid)
            annotation.subtitle = data.tag
            locationArr.append(annotation)
        }
        var returnAnno = [MKPointAnnotation]();
        let curr = CLLocation(latitude: location.latitude, longitude: location.longitude);
        
        for loc in locationArr {
            if curr.distance(from: CLLocation(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)) < 5000 {
                returnAnno.append(loc);
            }
        }
        returnAnno.append(annotation1);
        returnAnno.append(annotation2);
        return returnAnno;
    }
}

//  http://stackoverflow.com/questions/11077425/finding-distance-between-cllocationcoordinate2d-points
extension CLLocation {
    // In meteres
    // ignores altitude dif.
    class func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to);
    }
}
