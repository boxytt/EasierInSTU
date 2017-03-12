//
//  GetTimeStr.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/12/19.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import Foundation

public func getShowFormat(_ requestDate:Date) -> String {
    
    //获取当前时间
    let calendar = Calendar.current
    //判断是否是今天
    if calendar.isDateInToday(requestDate as Date) {
        //获取当前时间和系统时间的差距(单位是秒)
        //强制转换为Int
        let since = Int(Date().timeIntervalSince(requestDate as Date))
        //  是否是刚刚
        if since < 60 {
            return "刚刚"
        }
        //  是否是多少分钟内
        if since < 60 * 60 {
            return "\(since/60)分钟前"
        }
        //  是否是多少小时内
        return "\(since / (60 * 60))小时前"
    }
    
    //判断是否是昨天
    var formatterString = " HH:mm"
    if calendar.isDateInYesterday(requestDate as Date) {
        formatterString = "昨天" + formatterString
    } else {
        //判断是否是一年内
        formatterString = "MM-dd" + formatterString
        //判断是否是更早期
        
        let comps = calendar.dateComponents([Calendar.Component.year], from: requestDate, to: Date())
        
        if comps.year! >= 1 {
            formatterString = "yyyy-" + formatterString
        }
    }
    
    //按照指定的格式将日期转换为字符串
    //创建formatter
    let formatter = DateFormatter()
    //设置时间格式
    formatter.dateFormat = formatterString
    //设置时间区域
    formatter.locale = Locale(identifier: "en") as Locale!
    
    //格式化
    return formatter.string(from: requestDate as Date)
}

//func format(_ string: String) -> String {
//    var inputFormatter = DateFormatter()
//    inputFormatter.locale = NSLocale(localeIdentifier: "zh_CN") as Locale!
//    inputFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
//    let inputDate = inputFormatter.date(from: string)
//    
//    var outputFormatter = DateFormatter()
//    outputFormatter.locale = NSLocale.current
//    outputFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
//    
//    
//    
//    
//    
//    
//}
