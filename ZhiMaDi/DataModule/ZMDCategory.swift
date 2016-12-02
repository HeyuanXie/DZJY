//
//  ZMDCategory.swift
//  ZhiMaDi
//
//  Created by haijie on 16/5/17.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 类别
class ZMDCategory: NSObject {
    var Name : String!  //"床上用品",
    var Alias : String! //"Books",
    var Id : NSNumber!
}


class ZMDXHYCategory: NSObject {
    var Name : String!  //类别名称 护脊椎书包
    var PictureModel : ZMDPictureModel!  //图片地址,"/Media/Thumbs/defa/default-image-100.jpg"
    var Id : NSNumber!   //类别Id
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["PictureModel":ZMDPictureModel.classForCoder()]
    }
}

// 请求店铺数据中的类别
class ZMDStoreCategory: NSObject {
    var Disabled : Bool!
    var Selected : Bool!
    var Value : String!
    var Text : String!
    var Group: String?
}

