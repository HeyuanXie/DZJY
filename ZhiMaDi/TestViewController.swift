//
//  TestViewController.swift
//  ZhiMaDi
//
//  Created by admin on 17/1/6.
//  Copyright © 2017年 ZhiMaDi. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var lbl : UILabel!
    override func awakeFromNib() {
        self.lbl.bk_whenTapped { () -> Void in
            print("Tapped")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
