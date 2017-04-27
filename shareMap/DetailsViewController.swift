//
//  DetailsViewController.swift
//  shareMap
//
//  Created by RoYzH on 4/20/17.
//  Copyright © 2017 Likai Yan. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    var noteDetail: Notes!

    @IBOutlet weak var textField: UILabel!
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textField.text = noteDetail.text
        dateLabel.text = noteDetail.date
        rateLabel.text = noteDetail.rating
        userLabel.text = noteDetail.userName
        
        image.image = noteDetail.image
        
        textField.sizeToFit()
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
