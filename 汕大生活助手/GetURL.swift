//
//  GetURL.swift
//  汕大生活助手
//
//  Created by boxytt on 2016/11/23.
//  Copyright © 2016年 boxytt. All rights reserved.
//

import Foundation

public func getUrls(_ str: String) -> [String] {
    var urls = [String]()
    // 创建一个正则表达式对象
    do {
        let dataDetector = try NSDataDetector(types:
            NSTextCheckingTypes(NSTextCheckingResult.CheckingType.link.rawValue))
        // 匹配字符串，返回结果集
        let res = dataDetector.matches(in: str,
                                               options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                               range: NSMakeRange(0, str.characters.count))
        // 取出结果
        for checkingRes in res {
            urls.append((str as NSString).substring(with: checkingRes.range))
        }
    }
    catch {
        print(error)
    }
    return urls
    
}
