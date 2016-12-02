//
//  CountView.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/29.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 用于商品数量选择  --View
class CountView: UIView {
    var countForBounghtLbl : UIButton!
    var countForBounght : Int!
    var finished:((count:Int)->Void)!
    
    var theMaxNumber : Int!     //商品库存上限
    override init(frame:CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateUI() {
        var titles = ["-","\(self.countForBounght)","+"],i=0
        for title in titles {
            let btn = UIButton(frame: CGRect(x: 40*i, y: 0, width: 40, height: 40))
            if i == 1 {
                self.countForBounghtLbl = btn
            }
            btn.titleLabel?.font = defaultSysFontWithSize(15)
            btn.setTitle(title, forState: .Normal)
            btn.setTitleColor(defaultTextColor, forState: .Normal)
            btn.tag = 1000+i
            self.addSubview(btn)
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                if (btn.tag - 1000) == 0 && self.countForBounght != 0 {
                    self.countForBounght = self.countForBounght - 1
                    if self.countForBounght == 0 {
                        self.countForBounght = self.countForBounght + 1
                    }
                } else if (btn.tag - 1000) == 2 {
                    self.countForBounght = self.countForBounght + 1
//                    self.countForBounght = self.countForBounght+1 > self.theMaxNumber ? self.countForBounght : self.countForBounght+1
                }
                self.countForBounghtLbl.setTitle("\(self.countForBounght)", forState: .Normal)
                /*//隐藏库粗判断
                if self.countForBounght == self.theMaxNumber  {
                    ZMDTool.showActivityView(nil)
                    ZMDTool.showPromptView("库存有限")
                    ZMDTool.hiddenActivityView()
                    return
                }*/
                self.finished(count: self.countForBounght)
            })
            i++
        }
        self.addSubview(ZMDTool.getLine(CGRect(x: 40, y: 0, width: 0.5, height: 40)))
        self.addSubview(ZMDTool.getLine(CGRect(x: 80, y: 0, width: 0.5, height: 40)))
        
        ZMDTool.configViewLayerFrame(self)
    }
}
