//
//  WelcomeViewController.swift
//  UserLogin
//
//  Created by RoYzH on 4/9/17.
//  Copyright © 2017 RoYzH. All rights reserved.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*
        if FIRAuth.auth()?.currentUser != nil {
            self.presentLogin()
        }
        */
        
        DBUtil.sharedInstance.getById()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        /*
        if FIRAuth.auth()?.currentUser != nil {
            self.presentLogin()
        }
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Navigate to already login page
    func presentLogin () {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let TabBarVC: UITabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! UITabBarController
        self.present(TabBarVC, animated: true, completion: nil)
    }

}
