//
//  AddNoteViewController.swift
//  shareMap
//
//  Created by RoYzH on 4/11/17.
//  Copyright © 2017 Likai Yan. All rights reserved.
//

import UIKit
import SQLite
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class AddNoteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var Text: UITextView!
    
    var dataBack : [String] = ["April 24, 2017", "Nil", "3"]
    
    var currentUser = FIRAuth.auth()?.currentUser?.email
    
    let defaults = UserDefaults.standard
    
    
    var noteNumbers: Int = 0
    
    static var sharedInstance = DBUtil()
    var db:Connection?
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    let notes = Table("Note")
    let noteId = Expression<Int64>("noteId")
    let userForNote = Expression<String>("user")
    let locationIdForNote = Expression<Int64>("locationId")
    let notePicure = Expression<String>("picture") //TODO: modify the data format
    
    let text = Expression<String>("text")
    let date = Expression<String>("date")
    let rateForLocation = Expression<String>("rate")
    let tag = Expression<String>("tag")
    let isPrivate = Expression<Bool>("isPrivate")
    let longitude = Expression<Double>("longitude")
    let latitude = Expression<Double>("latitude")
    
    @IBOutlet weak var myImageView: UIImageView!

    @IBAction func importImage(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            else {
                print("Camera not available")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)

    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        myImageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        do{
            db = try Connection("\(path)/shareMap.sqlite")
            let query = notes.select(noteId,text)
                .filter(userForNote == currentUser!)
            
            let all = Array(try (db?.prepare(query))!)
            
            noteNumbers = all.count
        }
        catch{
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func more(_ sender: Any) {
        let more = MoreViewController(nibName: "MoreViewController", bundle: nil)
        
        navigationController?.pushViewController(more, animated: true)
        more.shdp=Text.text
        more.image="https://www.pexels.com/photo/landscape-mountains-nature-clouds-1029/"
    }

    

    @IBAction func publishNote(_ sender: UIButton) {
        // Upload Image to FireBase
        //let database = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference()
        let imageName = String(noteNumbers + 1) + ".jpg"
        let tempImageRef = storage.child(imageName)
        
        let image = myImageView.image
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        // Fetching URL of uploaded Image
        tempImageRef.put(UIImageJPEGRepresentation(image!, 0.8)!, metadata: metaData) { (data, error) in
            if error == nil {
                
                tempImageRef.downloadURL { (url, error) in
                    if error == nil {
                        
                        do{
                            self.db = try Connection("\(self.path)/shareMap.sqlite")
                            
                            
                            let urlString = url?.absoluteString;
                            
                            //let id =
                            try self.db?.run(self.notes.insert(self.userForNote <- self.currentUser!, self.notePicure <- urlString!,self.text <- self.Text.text,self.date <- self.dataBack[0],self.rateForLocation <- self.dataBack[2],self.tag <- "food",self.isPrivate <- false,self.latitude <-  self.defaults.double(forKey: "latitude"), self.longitude <-  self.defaults.double(forKey: "longitude")))
                            
                            print("=====================success upload")
                            
                            print(self.defaults.double(forKey: "latitude"))
                            print(self.defaults.double(forKey: "longitude"))
                          
                        }
                        catch{
                            print(error)
                        }
                    }
                }

            }
        }
     
        
 
        
        //get photo back
        
//        databaseRef.child("users").child(email).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
//        // check if user has photo
//        if snapshot.hasChild("userPhoto"){
//        // set image locatin
//        let filePath = "\(userID!)/\("userPhoto")"
//        // Assuming a < 10MB file, though you can change that
//        self.storageRef.child(filePath).dataWithMaxSize(10*1024*1024, completion: { (data, error) in
//        
//        let userPhoto = UIImage(data: data!)
//        self.userPhoto.image = userPhoto
//        })
//        }
//        })
        
    }

}
