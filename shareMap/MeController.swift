//
//  MeController.swift
//  shareMap
//
//  Created by Labuser on 4/10/17.
//  Copyright © 2017 Likai Yan. All rights reserved.
//
import UIKit
import SQLite
import FirebaseAuth

class MeController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var currentUser = FIRAuth.auth()?.currentUser?.email
    //var currentUser = "currentUser"
    
    
    var noteNumber = 0  //currentUser's notes
    
    var noteTitle : [String] = []
    var allNoteId : [Int64] = []
    
    static var sharedInstance = DBUtil()
    var db:Connection?
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    let notes = Table("Note")
    let noteId = Expression<Int64>("noteId")
    let userForNote = Expression<String>("user")
    let text = Expression<String>("text")
    let notePicure = Expression<String>("picture")

    
    
    
    @IBOutlet weak var tableView: UITableView!
    var theData: [String] = []
    
    
    private func setupTableView() {
        
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
//    {
//        if editingStyle == .delete
//        {
//            theData.remove(at: indexPath.row)
//            var array=UserDefaults.standard.stringArray(forKey: "movieKey") ?? [String]()
//            array.remove(at: indexPath.row)
//            UserDefaults.standard.set(array,forKey:"movieKey")
//            tableView.reloadData()
//        }
//    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel!.text = noteTitle[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteNumber
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

            let detailedView = Detailed();
            detailedView.currentUser = currentUser!
            //
            do{
                db = try Connection("\(path)/shareMap.sqlite")
                let query = notes.select(text,notePicure)
                    .filter(noteId == allNoteId[indexPath.row])
                
                let all = Array(try (db?.prepare(query))!)
                for note in all{
                    detailedView.currentText = note[text]
                    
                    let url = URL(string: note[notePicure])
                    
                    let data = try? Data(contentsOf: url!)
                    var image:UIImage;
                    
                    if data == nil {
                        image = #imageLiteral(resourceName: "348s")
                    }
                    else {
                        image = UIImage(data: data!)!
                    }
                    

                    detailedView.currentimage = image
                    
                }
            }
            catch{
                print(error)
            }
        
            self.navigationController?.pushViewController(detailedView, animated: true);
        
    }
    
    @IBAction func addNote(_ sender: UIButton) {
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
      
        do{
            db = try Connection("\(path)/shareMap.sqlite")
            let query = notes.select(noteId,text)
                .filter(userForNote == currentUser!)

            let all = Array(try (db?.prepare(query))!)
            
            noteNumber = all.count
            var title = " "
            for item in all{
                //http://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift-3
                title = String(item[noteId]) + " " + String(item[text])
                let sizestr = title.characters.count;
                let index = title.index(title.startIndex, offsetBy: sizestr > 50 ? 50 : (sizestr))
                
                noteTitle.append(title.substring(to: index)+"...")
                allNoteId.append(item[noteId])
            }
        }
        catch{
            print(error)
        }
       
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
