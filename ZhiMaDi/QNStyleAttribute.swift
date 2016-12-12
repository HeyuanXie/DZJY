//
//  QNStyleAttribute.swift
//  QooccShow
//
//  Created by LiuYu on 14/11/10.
//  Copyright (c) 2014年 Qoocc. All rights reserved.
//

/** 此文件中放置整个App的风格属性，如默认背景色，导航栏颜色 */

import UIKit.UIColor

// MARK: - 颜色
/// App主色 appThemeColor = appThemeColorNew
let appThemeColor = RGB(251,125,77,1.0)   //黄色
let appThemeColorNew = RGB(251,125,77,1.0)  //黄色
//从深到浅
// MARK: 导航栏
/// 导航栏文本颜色
let navigationTextColor = UIColor(red: 79/255.0, green: 79/255.0, blue: 79/255.0, alpha: 1.0)  //黑色
/// 导航栏背景颜色
let navigationBackgroundColor = UIColor.whiteColor()
/// 导航栏字体（titleView不允许被修改）
let navigationTextFont = UIFont.systemFontOfSize(19)

// 选中的文字 按扭 颜色
let defaultSelectColor = RGB(235,61,61,1.0)//UIColor(red: 235/255, green: 61/255, blue: 61/255, alpha: 1.0)  //红色

// 常规文字 （标题 icon）
let defaultTextColor = UIColor(red: 79/255, green: 79/255, blue: 79/255, alpha: 1.0) //黑色
let defaultTextSize = defaultSysFontWithSize(17)
// 辅助 次要 文字 icon
let defaultDetailTextColor = UIColor(red: 174/255, green: 174/255, blue: 174/255, alpha: 1.0) // 浅灰
// 小标题 描述  备注 评论 按扭  等
let defaultDetailTextSize = defaultSysFontWithSize(15)
/// 默认的分割线颜色
let defaultLineColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1.0)

/// 默认灰色
let defaultGrayColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)

/// 默认背景色
let defaultBackgroundColor = defaultGrayColor
/// 默认灰色背景
let defaultBackgroundGrayColor = defaultGrayColor

//let defaultButtonTextColor = UIColor(red: 174/255, green: 174/255, blue: 174/255, alpha: 1.0)
// 次要标题 分类  备注
let defaultButtonTextSize = defaultSysFontWithSize(13)

let defaultSysFontWithSize = { (size : CGFloat) -> UIFont in
    UIFont.systemFontOfSize(size)
}

//灰色不可按button背景色
let grayButtonBackgroundColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1)

let RGB = { (r : CGFloat,g: CGFloat,b: CGFloat,a: CGFloat) -> UIColor in
    return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
}
// 边距
let MarginLeft = 12

// MARK: - 统一的列表样式
//MARK:- 高度 & 宽度 缩放系数
let COEFFICIENT_OF_HEIGHT_ZOOM = kScreenHeight/667.0
let COEFFICIENT_OF_WIDTH_ZOOM = kScreenWidth/375.0

/// 默认tableView背景色
let tableViewdefaultBackgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
/// 默认高度
let tableViewCellDefaultHeight: CGFloat = 52.0
/// 默念head高度
let tableViewCellHeadDefaultHeight: CGFloat = 10.0
/// 默认cell背景色
let tableViewCellDefaultBackgroundColor = UIColor.whiteColor()
/// 默认内容字体
let tableViewCellDefaultTextFont = UIFont.systemFontOfSize(17)
/// 默认内容颜色
let tableViewCellDefaultTextColor = defaultTextColor
/// 默认详情字体
let tableViewCellDefaultDetailTextFont = UIFont.systemFontOfSize(14)
/// 默认详情颜色
let tableViewCellDefaultDetailTextColor = UIColor(white: 136/255.0, alpha: 1)

extension ZMDTool {
    /// 对UITableViewCell对象进行默认配置
    class func configTableViewCellDefault(cell: UITableViewCell) {
        cell.textLabel?.font = tableViewCellDefaultTextFont
        cell.textLabel?.textColor = tableViewCellDefaultTextColor
        cell.contentView.backgroundColor = tableViewCellDefaultBackgroundColor
        cell.detailTextLabel?.font = tableViewCellDefaultDetailTextFont
        cell.detailTextLabel?.textColor = tableViewCellDefaultDetailTextColor
        cell.selectionStyle = .None
    }
    /// 对UIView对象进行配置(cornerRadius)
    class func configViewLayer(view: UIView) {
        configViewLayerWithSize(view,size: 5)
    }
    class func configViewLayerWithSize(view: UIView,size:CGFloat) {
        view.layer.cornerRadius = size
        view.layer.masksToBounds = true
    }
    ///对UIView对象进行配置(borderWidth) 默认颜色 defaultLineColor
    class func configViewLayerFrame(view: UIView) {
        self.configViewLayerFrameWithColor(view, color: defaultLineColor)
    }
    ///对UIView对象进行配置(borderWidth、borderColor)
    class func configViewLayerFrameWithColor(view: UIView,color: UIColor) {
        view.layer.borderWidth = 0.5
        view.layer.borderColor = color.CGColor
    }
    /// 对UIView对象进行配置(cornerRadius)
    class func configViewLayerRound(view: UIView) {
        view.layer.cornerRadius = view.bounds.size.width/2
        view.layer.masksToBounds = true
    }
}


