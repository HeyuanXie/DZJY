//
//  GoodsScoreViewController.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/13.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 星星评价控件
class GoodsScoreView: UIView{
    var touchTag = -1
    var finished : ((str:String,point:Int) ->Void)!
    override init(frame:CGRect){
        super.init(frame: frame)
        self.updateUI()
    }
    init(frame: CGRect,finished:((str:String,point:Int) ->Void)) {
        super.init(frame: frame)
        self.finished = finished
        self.updateUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateUI() {
        let padding = 6
        for index in [0,1,2,3,4] {
            let x = (26+padding)*index
            
            let btn = UIButton(type: UIButtonType.Custom)
            btn.adjustsImageWhenHighlighted = false
            btn.frame = CGRect(x:x, y:0, width: 26, height: 26)
            btn.setImage(UIImage(named: "user_pingfen_unselected"), forState: .Normal)
            btn.setImage(UIImage(named: "user_pingfen_selected"), forState: .Selected)
            self.addSubview(btn)
            btn.tag = 1000 + index
            btn.rac_signalForControlEvents(.TouchUpInside).subscribeNext({ (sender) -> Void in
                self.touchTag = sender.tag
                self.updateStarBtn()
                self.finished(str: sender.tag > 1002 ? "满意" : "一般",point:sender.tag-1000)
            })
        }
    }
    func updateStarBtn() {
        for index in [0,1,2,3,4] {
            let btn = self.viewWithTag(1000+index) as! UIButton
            btn.selected =  btn.tag <= self.touchTag ? true : false
        }
    }
}

