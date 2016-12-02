//
//  ZMDAlertView.swift
//  ZhiMaDi
//
//  Created by admin on 16/11/7.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

class ZMDAlertView: UIView {
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    class func view() -> ZMDAlertView {
//        let nibView1 = NSBundle.mainBundle().loadNibNamed("ZMDAlertView", owner: nil, options: nil) as NSArray
        let nibView1 = NSArray()
        let productView = nibView1.objectAtIndex(0) as? ZMDAlertView
        productView!.frame.size = CGSizeMake(kScreenWidth-44, 205)
        productView!.frame.origin = CGPoint(x: 22, y:(kScreenHeight - 205)/2-32)
        return productView!
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        ZMDTool.configViewLayer(self.okBtn)
        ZMDTool.configViewLayer(self)
    }
    func updateUI(title:String,okText:String,cancelText:String){
        let attr = NSMutableAttributedString(string: title)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        paragraphStyle.alignment = .Center
        attr.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, title.characters.count))
        self.cancelBtn.setTitle(cancelText, forState: UIControlState.Normal)
        self.okBtn.setTitle(okText, forState: UIControlState.Normal)
        titleLbl.attributedText = attr
    }
}

