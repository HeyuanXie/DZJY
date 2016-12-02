//
//  TimeLabel.swift
//  Time_Test
//
//  Created by 伯驹 黄 on 16/2/2.
//  Copyright © 2016年 伯驹 黄. All rights reserved.
//

import UIKit

class TimeLabel: UILabel {
    private let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
    
    private var endTime: String!
    private var isTiming = true
    
    convenience init (frame: CGRect, endTime: String, textColor: UIColor = UIColor.blackColor(), bgColor: UIColor = UIColor.whiteColor()) {
        self.init()
        self.frame = frame
        self.textColor = textColor
        self.backgroundColor = bgColor
        self.endTime = endTime
    }
    
    
    
    private func gcd(var timeCount: Int) {
        dispatch_source_set_timer(timer, dispatch_walltime(nil, 0), NSEC_PER_SEC, 0)
        dispatch_source_set_event_handler(timer, { () -> Void in
            if timeCount <= 0 {
                dispatch_source_cancel(self.timer)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.timeformatFromSeconds(timeCount)
                })
            } else {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.timeformatFromSeconds(timeCount)
                })
                timeCount--
            }
        })
        dispatch_resume(timer)
    }
    
    private func timeformatFromSeconds(seconds: Int) {
        if seconds > 0 {
            var text = "剩余:"
            if (seconds / 86400) >= 1 {
                text += "\(seconds / 86400)天"
                if (seconds % 86400 / 3600) >= 1 {
                    text += "\(seconds % 86400 / 3600)小时"
                    if (seconds % 3600 / 60) >= 1 {
                        text += "\(seconds % 3600 / 60)分\(seconds % 60)秒"
                    } else {
                        text += "00分\(seconds % 60)秒"
                    }
                } else {
                    text += "00小时"
                    if (seconds % 86400 / 60) >= 1 {
                        text += "\(seconds % 86400 / 60)分\(seconds % 60)秒"
                    } else {
                        text += "00分\(seconds % 60)秒"
                    }
                }
            } else {
                text += "0天"
                if (seconds / 3600) >= 1 {
                    text += "\(seconds / 3600)小时"
                    if (Int(seconds) % 3600 / 60) >= 1 {
                        text += "\(seconds % 3600 / 60)分\(seconds % 60)秒"
                    } else {
                        text += "00分\(seconds % 60)秒"
                    }
                } else {
                    text += "00小时"
                    if (seconds / 60) >= 1 {
                        text += "\(seconds / 60)分\(seconds % 60)秒"
                    } else {
                        text += "00分\(seconds % 60)秒"
                    }
                }
            }
            self.text = text
        } else {
            self.text = "抢购已结束"
        }
        self.sizeToFit()
    }
    
    func setEndTime(time:String) -> Void {
        self.endTime = time
    }
    
    func start() {
        if isTiming {
            isTiming = false
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let endTime = dateFormatter.dateFromString(self.endTime)
            let seconds = Int((endTime?.timeIntervalSinceNow)!) + 1
            gcd(seconds)
        }
    }
    
    func stop() {
        isTiming = true
        dispatch_suspend(timer)
    }
}
