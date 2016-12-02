//
//  ZMDShoppingProduct.swift
//  ZhiMaDi
//
//  Created by haijie on 16/6/2.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 购物车
class ZMDShoppingItem: NSObject {
    var Id : NSNumber!
    var ProductId : NSNumber!
    var ProductName : String!
    var Quantity : NSNumber!                        // 数量
    var AttributeInfo : String!                     // 属性
    var SubTotal : String!                          // 小计
    var UnitPrice : String!                         // 单价
    var Warnings : NSArray!
    var DefaultPictureModel : ZMDPictureModel?
    var Picture : ZMDPictureModel?
    var StoreId : Int!  //测试分组用
    var Store : ZMDStoreDetail!
    
    var IsShipEnabled :Bool!
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["DefaultPictureModel":ZMDPictureModel.classForCoder(),"Store":ZMDStoreDetail.classForCoder()]
    }
}
