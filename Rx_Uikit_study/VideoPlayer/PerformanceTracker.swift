//
//  PerformanceTracker.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/5/5.
//

import CoreFoundation


// 创建一个调试工具类
class PerformanceTracker {
    static var lastEventTime: CFAbsoluteTime = 0
    static func trackEvent(_ name: String) {
        let now = CFAbsoluteTimeGetCurrent()
        let diff = lastEventTime > 0 ? String(format: "距上次: %.4f秒", now - lastEventTime) : "首次记录"
        print("⏱️ [\(name)] 时间: \(now) - \(diff)")
        lastEventTime = now
    }
}
