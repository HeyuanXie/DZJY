//
//  ZMDMultiselectView.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/8.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 多个btn 流水展示(气泡)
class ZMDMultiselectView: UIView {
    var selectBtn : UIButton!
    var titles : [String]!
    var finished : ((index:Int)->Void)!
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    init(frame: CGRect,titles:[String]) {
        super.init(frame: frame)
        self.titles = titles
        self.updateUI([])
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateUI(menuTitle:[String]) {
        let getBtn = { (text : String,index : Int) -> UIButton in
            let btn = ZMDTool.getMutilButton(CGRect.zero, textForNormal: text, textColorForSelect:UIColor.whiteColor(),fontSize: 13, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                self.selectBtn.selected = false
                (sender as! UIButton).selected = true
                self.selectBtn = (sender as! UIButton)
                self.finished(index: sender.tag)
                // 我要干嘛   .。(点击气泡的响应)
            })
            btn.setBackgroundImage(UIImage.colorImage(RGB(240,240,240,1.0)), forState: .Normal)
            btn.setBackgroundImage(UIImage.colorImage(RGB(235,61,61,1.0)), forState: .Selected)
            ZMDTool.configViewLayerWithSize(btn, size: 10)
            return btn
        }
        var x = CGFloat(12)
        var y = 12
        let space = CGFloat(10)
        var index = 0
        for title in titles {
            let sizeTmp = title.sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100) //名宽度
            let xTmp = x + space * 2 + sizeTmp.width + 20
            let btn = getBtn(title,index)
            btn.tag = index++
            if xTmp < kScreenWidth {
                btn.frame = CGRectMake(x, CGFloat(y),sizeTmp.width + 20, 26)
                self.addSubview(btn)
                x = x + sizeTmp.width + 20 + space
            } else {
                y += 38
                x = 12 + sizeTmp.width + 20 + space
                btn.frame = CGRectMake(12, CGFloat(y),sizeTmp.width + 20, 26)
                self.addSubview(btn)
            }
            if btn.tag == 0 {
                btn.selected = true
                self.selectBtn = btn
            }
        }
    }
    
    class func getHeight(titles:[String]) -> CGFloat {
        var x = CGFloat(14)
        var y = CGFloat(50)
        let space = CGFloat(12)
        for title in titles {
            let sizeTmp = title.sizeWithFont(UIFont.systemFontOfSize(15), maxWidth: 100) //名宽度
            let xTmp = x + space + sizeTmp.width + 20 + 12
            if xTmp > kScreenWidth {
                y += 38
                x = 14 + sizeTmp.width + 20
            } else {
                x = x + space + sizeTmp.width + 20
            }
        }
        return  CGFloat(y)
    }
}
