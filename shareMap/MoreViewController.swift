//
//  MoreViewController.swift
//  shareMap
//
//  Created by enowang on 4/18/17.
//  Copyright © 2017 Likai Yan. All rights reserved.
//

import UIKit
import TwitterKit



class MoreViewController: UIViewController,UINavigationControllerDelegate {
    
    //store the push back data: date and rate for the location,data[0] is the date and data[1] is the time
    var dataBack: [String] = []
    
    var image:String!
    
    var shdp:String!
    
    @IBOutlet weak var date: UIDatePicker!

    @IBOutlet weak var rate: CosmosView!
    
    @IBAction func PickDate(_ sender: UIDatePicker) {
        let format = DateFormatter()
        format.dateFormat = "MMMM dd, YYYY"
        dataBack[0] = format.string(from: date.date)
        
        format.dateFormat = "hh:mm a"
        dataBack[1] = format.string(from: date.date)
    }
    

    @IBAction func twitter(_ sender: UIButton) {
        
        let composer = TWTRComposer()
        
        composer.setText(shdp)
        composer.setImage(UIImage(named: "1"))
        
        // Called from a UIViewController
        
        composer.show(from: self) { result in
            if (result == TWTRComposerResult.cancelled) {
                print("Tweet composition cancelled")
            }
            else {
                print("Sending tweet!")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self

        // Do any additional setup after loading the view.
        let format = DateFormatter()
        format.dateFormat = "MMMM dd, YYYY"
        dataBack.append(format.string(from: date.date))
        
        format.dateFormat = "hh:mm a"
        dataBack.append(format.string(from: date.date))
        
        let rating = Int(rate.rating.rounded())
        dataBack.append(String(rating))
        
        
        let content : FBSDKShareLinkContent =
            FBSDKShareLinkContent()
        content.contentDescription = shdp
        content.imageURL = URL(string: image)
        
        let button : FBSDKShareButton = FBSDKShareButton()
        button.shareContent = content
        button.frame=CGRect(x: 210, y: 300, width: 80, height: 30)
        self.view.addSubview(button)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension MoreViewController {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        (viewController as? AddNoteViewController)?.dataBack = dataBack
    }
}
