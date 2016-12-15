//
//  QNFormatTool.swift
//  QooccHealth
//
//  Created by LiuYu on 15/4/27.
//  Copyright (c) 2015年 Juxi. All rights reserved.
//

import Foundation

/** 格式化工具 */
class QNFormatTool: NSObject {
}

/// 默认的输入日期格式
private let defaultDateInputFormat = "yyyy-MM-dd HH:mm:ss"
private let defaultDateInputFormatTmp = "yyyy-MM-ddTHH:mm:ss+08:00"

/// 默认的输出日期格式
private let defaultDateOutputFormat = "MM-dd HH:mm"
/// 输出日期格式
private let defaultDateOutputFormat02 = "MM-dd HH:mm"
// MARK: - 时间格式化相关
extension QNFormatTool {
    
    /**
    将时间字符串转化成时间对象
    
    :param: dateString 时间字符串
    :param: format     格式
    
    :returns: 时间
    */
    class func date(dateString: String, format: String = defaultDateInputFormat) -> NSDate? {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.dateFromString(dateString)
    }
    
    /**
    将时间转换成时间字符串
    
    :param: date   时间对象
    :param: format 转换出来的时间字符串格式
    
    :returns: 时间字符串
    */
    class func dateString(date: NSDate, format: String = defaultDateOutputFormat) -> String {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.stringFromDate(date)
    }
    /**
     将时间转换成时间字符串
     
     :param: date   时间对象
     :param: format 转换出来的时间字符串格式
     
     :returns: 时间字符串
     */
    class func dateString02(date: NSDate, format: String = defaultDateOutputFormat02) -> String {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.stringFromDate(date)
    }
    /**
    将时间字符串按一定的格式转换
    
    :param: dateString   输入时间字符串
    :param: inputFormat  输入时间字符串的格式
    :param: outputFormat 输出时间字符串的格式
    
    :returns: 转换后的时间字符串
    */
    class func dateString(dateString: String, inputFormat: String = defaultDateInputFormat, outputFormat: String = defaultDateOutputFormat) -> String? {
        if let date = self.date(dateString, format: inputFormat) {
            return self.dateString(date, format: outputFormat)
        }
        return nil
    }
    
    /**
    将时间字符串按一定的格式转换
    
    :param: dateString   输入字符串日期
    :param: inputFormat  输入格式
    :param: refrenceDate 参考日期
    */
    class func dateQNString(dateString: String, inputFormat: String = defaultDateInputFormat, refrenceDate: NSDate = NSDate()) -> String? {
        return self.dateQNString(self.date(dateString, format: inputFormat)!, refrenceDate: refrenceDate)
    }
    
    /**
    将时间字符串按一定的格式转换
    
    :param: date         输入日期
    :param: refrenceDate 参考时间
    */
    class func dateQNString(date: NSDate, refrenceDate: NSDate = NSDate()) -> String? {
        // 获取年月日
        let components1 = NSCalendar.currentCalendar().components([.Day , .Month , .Year], fromDate: date)
        let components2 = NSCalendar.currentCalendar().components([.Day , .Month , .Year], fromDate: refrenceDate)
        
        if components1.year != components2.year { // 年不同，全部显示
            return QNFormatTool.dateString(date, format: "yyyy-MM-dd HH:mm")
        }
        else if components1.month != components2.month || components1.day != components2.day { // 年相同，日期不同
            return QNFormatTool.dateString(date, format: "MM-dd HH:mm")
        }
        else { // 同一天的
            return QNFormatTool.dateString(date, format: "HH:mm")
        }
    }
    
    class func getDaysWithDateString(dateStr1:String) -> String {
        let date1 = QNFormatTool.date(dateStr1, format: "yyyy-MM-dd")
        let time = date1?.timeIntervalSinceNow
        let days = Int(time!)/(3600*24)
        return "\(days)"
    }
}

// MARK: - 消息未读数的格式化
extension QNFormatTool {
    /// 消息未读数的格式化
    class func notReadCount(count: Int) -> String? {
        switch count {
        case 1...99:
            return String(count)
        case 100..<Int.max:
            return "99+"
        default:
            return nil
        }
    }
}











