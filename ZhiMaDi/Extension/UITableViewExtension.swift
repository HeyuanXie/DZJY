//
//  UITableViewExtension.swift
//  ZhiMaDi
//
//  Created by haijie on 16/4/7.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit

extension UITableView {
    //添加尾部视图
    func addFootBtn(btnText : String,blockForCli : ((AnyObject!) -> Void)!) {
        let footView = UIView(frame: CGRectMake(0, 0, kScreenWidth, 110))
        footView.backgroundColor = UIColor.clearColor()
        let btn = ZMDTool.getButton(CGRect(x: 12, y: 60, width: kScreenWidth - 24, height: 50), textForNormal: btnText, fontSize: 20, textColorForNormal: UIColor.whiteColor(), backgroundColor: RGB(235,61,61,1.0),blockForCli: blockForCli)
        ZMDTool.configViewLayerWithSize(btn, size: 25)
        footView.addSubview(btn)
        self.tableFooterView = footView
    }
}

extension UITableViewCell {
    /**cell添加分割线*/
    func addLine(hiddenLine isHidden:Bool = false,leftOffset:CGFloat = 0,rightOffset : CGFloat = 0) {
        var customLine = self.viewWithTag(100011)
        if customLine == nil {
            let line = ZMDTool.getLine(CGRect.zero)
            line.tag = 100011
            self.contentView.addSubview(line)
            line.snp_makeConstraints(closure: { (make) -> Void in
                if rightOffset == 0 {
                    make.width.equalTo(kScreenWidth - leftOffset)
                } else {
                    make.right.equalTo(self.contentView).offset(rightOffset)
                }
                make.bottom.equalTo(self.contentView).offset(0)
                make.height.equalTo(0.5)
                make.left.equalTo(leftOffset)
            })
            customLine = line
        }
        customLine!.hidden = isHidden
    }

}
