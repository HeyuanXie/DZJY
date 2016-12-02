//
//  RecommendView.swift
//  ZhiMaDi
//
//  Created by admin on 16/11/30.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

class RecommendView: UIView {
    
    @IBOutlet weak var topLbl : UILabel!
    @IBOutlet weak var botLbl : UILabel!

}

class PickView : UIView,UITextFieldDelegate {
    let kLowFieldTag = 10000,kHighFieldTag = 10001,kLimitFieldTag = 10002
    @IBOutlet weak var lowTextField : UITextField!
    @IBOutlet weak var highTextField : UITextField!
    @IBOutlet weak var limitTextField : UITextField!
    @IBOutlet weak var submitBtn : UIButton!
    var lower : Int!
    var higher : Int!
    var limit : Int!
    var submitBtnFinished : (()->Void)!
    
    @IBAction func submit(sender: AnyObject) {
        self.endEditing(true)
        self.submitBtnFinished()
    }
    override func awakeFromNib() {
        ZMDTool.configViewLayer(self.submitBtn)
        self.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 174)
        self.lowTextField.keyboardType = .NumberPad
        self.highTextField.keyboardType = .NumberPad
        self.limitTextField.keyboardType = .NumberPad
    }
    
    func checkData() -> Bool {
        if let lower = self.lower,higher = self.higher {
            if self.lower > self.higher {
                let tmp = self.lowTextField.text
                self.lowTextField.text = self.highTextField.text
                self.highTextField.text = tmp
                return false
            }
        }
        
        if let limit = self.limit where limit < 0 {
            ZMDTool.showPromptView("起订量必须大于零")
            return false
        }
        return true
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch textField.tag {
        case kLowFieldTag:
            self.lower = ((self.lowTextField.text?.componentsSeparatedByString(" ").last)! as NSString).integerValue
            return
        case kHighFieldTag:
            self.higher = (self.highTextField.text as! NSString).integerValue
            return
        case kLimitFieldTag:
            self.limit = (self.limitTextField.text as! NSString).integerValue
            return
        default:
            break
        }
    }
}
