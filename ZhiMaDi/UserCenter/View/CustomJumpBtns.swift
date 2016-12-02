//
//  CustomJumpBtns.swift
//  ZhiMaDi
//
//  Created by haijie on 16/3/30.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 自定义多个btn的View  有个下标线
class CustomJumpBtns: UIView {
    var redLine : UIView!
    var textColorForNormal : UIColor!
    var textColorForSelect : UIColor!
    var selectBtn : UIButton!
    var menuTitle:[String]!
    var finished : ((index:Int)->Void)!
    var btnTextSize = CGFloat(14)
    var IsLineAdaptText = true  //redLine是否随字宽度改变
    var setSelectedBtn :((btn:UIButton)->Void)!
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    init(frame: CGRect,menuTitle:[String],textColorForNormal:UIColor = defaultTextColor,textColorForSelect:UIColor = RGB(235,61,61,1.0),IsLineAdaptText : Bool = true) {
        self.menuTitle = menuTitle
        self.textColorForNormal = textColorForNormal
        self.textColorForSelect = textColorForSelect
        self.IsLineAdaptText = IsLineAdaptText
        super.init(frame: frame)
        self.updateUI(self.menuTitle)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateUI(menuTitle:[String]) {
        redLine = ZMDTool.getLine(CGRect(x: 0, y: CGRectGetHeight(self.frame) - 2, width: kScreenWidth/CGFloat(menuTitle.count), height: 2))
        redLine.backgroundColor = textColorForSelect
        self.addSubview(redLine)
        var i = 0
        let width = kScreenWidth/CGFloat(menuTitle.count),height = CGRectGetHeight(self.frame) - 3.5
        self.setSelectedBtn = { (btn : UIButton) in
            self.selectBtn = btn
            self.selectBtn.selected = true
            //点击btn，redLine的动画
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                let selectBtnFrame = self.selectBtn.frame
                if self.IsLineAdaptText {
                    let size = self.selectBtn.titleLabel!.text?.sizeWithFont(UIFont.systemFontOfSize(self.btnTextSize), maxWidth: 100)
                    self.redLine.frame = CGRect(x: CGRectGetMinX(selectBtnFrame) + (CGRectGetWidth(selectBtnFrame) - size!.width)/2, y: CGRectGetHeight(self.frame) - 3.5, width:  size!.width, height: 3.5)
                } else {
                    self.redLine.frame = CGRect(x: CGRectGetMinX(selectBtnFrame), y: CGRectGetHeight(self.frame) - 3.5, width:kScreenWidth/CGFloat(menuTitle.count), height: 3.5)
                }
                
            })
            if self.finished != nil {
                self.finished(index: btn.tag - 1000)
            }
        }
        for title  in menuTitle {
            let x = CGFloat(i) * width
            let btn = ZMDTool.getButton(CGRect(x: x, y: 0, width: width, height: height), textForNormal: title, fontSize: btnTextSize,textColorForNormal:self.textColorForNormal, backgroundColor: UIColor.clearColor(), blockForCli: { (sender) -> Void in
                self.selectBtn.selected = false
                self.setSelectedBtn(btn: sender as! UIButton)
            })
            btn.setTitle(title, forState: .Selected)
            btn.setTitleColor(textColorForSelect, forState: .Selected)
            btn.titleLabel?.numberOfLines = 2
            btn.titleLabel?.textAlignment = .Center
            btn.tag = 1000 + i
            self.addSubview(btn)
            if i == 0{
                self.setSelectedBtn(btn: btn)
            }
            i++
        }
        self.addSubview(ZMDTool.getLine(CGRect(x: 0, y:self.frame.height-0.5, width:CGRectGetWidth(self.frame), height:0.5)))
    }
    // 分割线
    func addSeparatedLine(color:UIColor = defaultLineColor) {
        let width = kScreenWidth/CGFloat(menuTitle.count)
         var i = 1
        for _ in menuTitle {
            let line = ZMDTool.getLine(CGRect(x: width*CGFloat(i), y:(self.frame.height-25)/2, width:0.5, height:25))
            line.backgroundColor = color
            self.addSubview(line)
            i++
        }
    }
}
