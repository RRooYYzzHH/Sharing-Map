//
//  NotesCollectionViewController.swift
//  shareMap
//
//  Created by RoYzH on 4/20/17.
//  Copyright © 2017 Likai Yan. All rights reserved.
//

import UIKit
import SQLite
import FirebaseAuth


private let reuseIdentifier = "Cell"

class NotesCollectionViewController: UICollectionViewController {

    @IBOutlet var NotesCV: UICollectionView!
    
    
    var currentUser = FIRAuth.auth()?.currentUser?.email
    
    let defaults = UserDefaults.standard
    
//    var currLati = String(defaults.double(forKey: "latitude"))
//    var currLong = String(defaults.double(forKey: "longitude"))
    
    var noteNumber = 0
    
    var noteTitle : [Notes] = []
    
    // Fetching Data
    static var sharedInstance = DBUtil()
    var db:Connection?
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    let notes = Table("Note")
    let noteId = Expression<Int64>("noteId")
    let userForNote = Expression<String>("user")
    let text = Expression<String>("text")
    let notePicure = Expression<String>("picture")
    
    let date = Expression<String>("date")
    let rateForLocation = Expression<String>("rate")

    let longitude = Expression<Double>("longitude")
    let latitude = Expression<Double>("latitude")
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Go to DetailsViewController
        if segue.identifier == "details" {
            let svc = segue.destination as! DetailsViewController
            let buttonSender = sender as! UIButton
            let index = buttonSender.tag
            svc.noteDetail = noteTitle[index]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        noteTitle.removeAll()
        
        print("Begin")
        
        do{
            db = try Connection("\(path)/shareMap.sqlite")
            
            let query = notes.select(noteId,text,userForNote,rateForLocation,date,notePicure)
                .filter( latitude == defaults.double(forKey: "latitude") && longitude == defaults.double(forKey: "longitude"))
            
            let all = Array(try (db?.prepare(query))!)
            
            noteNumber = all.count
            
            print("========" + String(noteNumber))
            
            for item in all{
                // Get Note from Data Base
                let noteID = String(item[noteId])
                let noteText = String(item[text])
                let usernow = String(item[userForNote])
                let rateNow = String(item[rateForLocation])
                let dateNow = String(item[date])
                
                let url = URL(string: item[notePicure])
                
                let data = try? Data(contentsOf: url!)
                var image:UIImage;
                
                if data == nil {
                    image = #imageLiteral(resourceName: "348s")
                }
                else {
                    image = UIImage(data: data!)!
                }
                
                let photo : UIImage = image
                
//                databaseRef.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
//                    // check if user has photo
//                    if snapshot.hasChild("userPhoto"){
//                        // set image locatin
//                        let filePath = "\(userID!)/\("userPhoto")"
//                        // Assuming a < 10MB file, though you can change that
//                        self.storageRef.child(filePath).dataWithMaxSize(10*1024*1024, completion: { (data, error) in
//                            
//                            let userPhoto = UIImage(data: data!)
//                            self.photo = userPhoto
//                        })
//                    }
//                })
                
                
                //
                // This is to create new noteTitle. I have already got noteId and text.
                // I need userName, rate, date and image. Up to now, I just default these.
                // Also, we need to do a location comparasion base on longitude and latitude.
                //
                noteTitle.append(Notes(noteID: noteID, text: noteText!, userName: usernow!, rating: rateNow!, date: dateNow!, image: photo))
                
                //let longi = String(describing: location[longitude])
                
            }
            //            for note in try db?.prepare(note.filter(userForNoteId == 1)!)! {
            //                print("===========================id: \(note[noteId])")
            //                // id: 1, email: alice@mac.com
            //            }
        }
        catch{
            print(error)
        }
        NotesCV.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
    }



    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return noteTitle.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCell", for: indexPath) as! NoteCell
    
        
        // Configure the cell
        let btnImage = noteTitle[indexPath.row].image
        cell.imageButton.setBackgroundImage(btnImage, for: UIControlState.normal)
        cell.imageButton.tag = indexPath.row
        cell.userName.text = noteTitle[indexPath.row].userName
        
        return cell
    }

    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
