//
//  SignUpViewController.swift
//  shareMap
//
//  Created by RoYzH on 4/9/17.
//  Copyright © 2017 Likai Yan. All rights reserved.
//

import UIKit
import FirebaseAuth
import SQLite

class SignUpViewController: UIViewController {
    
    static var sharedInstance = DBUtil()
    var db:Connection?
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccount(_ sender: Any) {
        // No email input or password input
        if emailTextField.text == "" || passwordTextField.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter an email and password for creating account!", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
        }
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                
                if let firebaseError = error {
                    let alertController = UIAlertController(title: "Oops!", message: firebaseError.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                print("Successful Create Account!")
                
                // insert the user account into the database
                do{
                    self.db = try Connection("\(self.path)/shareMap.sqlite3")
                    let users = Table("User")
                    let userName = Expression<String?>("name")
                    let userPassword = Expression<String>("password")
                    let userProfile = Expression<String>("profile")
                    
                    try self.db?.run(users.insert(userName <- self.emailTextField.text , userPassword <- self.passwordTextField.text!, userProfile <- "no profile"))
                    
//                    for user in try self.db!.prepare(users) {
//                        print("----------------------name: \(user[userName])")
//                    }
                }
                catch{
                    print(error)
                }
                self.presentHomePage()
            })
        }
    }

    func presentHomePage () {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let welcomeVC: WelcomeViewController = storyboard.instantiateViewController(withIdentifier: "StartPage") as! WelcomeViewController
        self.present(welcomeVC, animated: true, completion: nil)
    }
}
