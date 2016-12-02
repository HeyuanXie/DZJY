//
//  ZMDOrder.swift
//  ZhiMaDi
//
//  Created by haijie on 16/5/24.
//  Copyright © 2016年 ZhiMaDi. All rights reserved.
//

import UIKit
// 订单
class ZMDOrder: NSObject {
    var OrderNumber:String!        //

}

class ZMDOrder2: NSObject {
    var StoreId:NSNumber! //1
    var OrderStatus:String! //  "已取消"
    var PaymentMethod :String!  //"支付宝付款"
    var OrderSubtotal :String!     //"¥5,625.00"
    var OrderShipping :String!      //5.00
    var OrderTotal :String!     //"¥5,630.00"
    var Items: [ZMDOrderItem]!
    var Id: NSNumber!
    var OrderStatusId:NSNumber!
    var ShippingStatusId:NSNumber!
    var PaymentStatusId:NSNumber!
    
    /** 获得各种订单状态*/
    func orderStatu() -> String {
        if let OrderStatus = OrderStatus,OrderStatusId = OrderStatusId,PaymentStatusId = PaymentStatusId,ShippingStatusId = ShippingStatusId,PaymentMethod=PaymentMethod {
            if OrderStatus == "已取消" || OrderStatus == "已完成" {
                return OrderStatus
            }
            if OrderStatusId == 10 && PaymentMethod == "货到付款" {
                return "处理中"
            }
            if PaymentStatusId == 10 && ShippingStatusId == 20 {
                return PaymentMethod == "货到付款" ? "待发货" : "待付款"
            }
            return ShippingStatusId == 20 ? "待发货" : "待收货"
        }
        return ""
    }
    
    override static func mj_objectClassInArray() -> [NSObject : AnyObject]! {
        return ["Items":ZMDOrderItem.classForCoder()]
    }
    
}
class ZMDOrderItem: NSObject {
    var ProductId : NSNumber!
    var ProductName : String!
    var PictureUrl: String!
    var ProductType: NSNumber!
    var UnitPrice: String!
    var SubTotal: String!
    var Quantity: NSNumber!
    var AttributeInfo: String!
    var Id: NSNumber!
}
