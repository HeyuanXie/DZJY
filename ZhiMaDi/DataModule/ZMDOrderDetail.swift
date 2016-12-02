//
//  ZMDOrderDetail.swift
//  ZhiMaDi
//
//  Created by haijie on 16/6/23.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 订单详情 用
class ZMDOrderDetail: NSObject {
    var OrderTotal : String!
    var Id : NSNumber!
    var OrderStatusId : NSNumber!
    var ShippingStatusId : NSNumber!
    var PaymentStatusId : NSNumber!
    var OrderItems : [ZMDOrderDetailOrderItems]!
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["OrderItems":ZMDOrderDetailOrderItems.classForCoder()]
    }
}
class ZMDOrderDetailOrderItems: NSObject {
    var UnitPriceInclTax : String!
    var Quantity : NSNumber!
    var AttributeDescription : String!
    var Product : ZMDOrderDetailOrderItemsProduct!
}
class ZMDOrderDetailOrderItemsProduct: NSObject {
    var ProductPictures:[ZMDOrderDetailOrderItemsProductPictureId]?
    var Name : String!
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["ProductPictures":ZMDOrderDetailOrderItemsProductPictureId.classForCoder()]
    }
}
class ZMDOrderDetailOrderItemsProductPictureId: NSObject {
    var PictureId : NSNumber!
}

//第二种方式请求   订单详情
class ZMDOrderDetail2: NSObject {
    var OrderNumber : String! //订单号
    var OrderTotal : String! //"¥5,630.00"
    var OrderStatus:String! //“待处理”
    var OrderStatusId : NSNumber!   //0
    var PaymentStatusId : NSNumber!     //0
    var ShippingStatusId : NSNumber!    //0
    var Store:ZMDStoreDetail!
    var Order:ZMDOrder2!
    
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["Store":ZMDStoreDetail.classForCoder(),"Order":ZMDOrder2.classForCoder()]
    }
}
