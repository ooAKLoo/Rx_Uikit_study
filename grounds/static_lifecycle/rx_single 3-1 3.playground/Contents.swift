//: A UIKit based Playground for presenting user interface

import RxSwift

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

import RxSwift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// 管理类
class Manager {
    
    static func starCall(progressCallback: @escaping (Int) -> Void){
        let util = Util()
        util.startMonitoring(progressCallback: progressCallback)
    }
}

// 工具类
class Util {
    private let disposeBag = DisposeBag()
    
    // 启动进度监控（唯一暴露的接口）
    func startMonitoring(progressCallback: @escaping (Int) -> Void) {
        checkPowerStatus()
            .flatMap { isPowerOn -> Observable<Bool> in
                guard isPowerOn else { return Observable.just(false) }
                return self.checkWiFiStatus()
            }
            .flatMap { isWiFiConnected -> Observable<Int> in
                guard isWiFiConnected else { return Observable.empty() }
                return self.observeProgress()
            }
            .subscribe(onNext: { progress in
                progressCallback(progress)
            })
            .disposed(by: disposeBag)
    }
    
    // 私有方法：检查开机状态
    private func checkPowerStatus() -> Observable<Bool> {
        return Observable.just(true)  // 简化示例
    }
    
    // 私有方法：检查WiFi状态
    private func checkWiFiStatus() -> Observable<Bool> {
        return Observable.just(true)  // 简化示例
    }
    
    // 私有方法：监听进度
    private func observeProgress() -> Observable<Int> {
        return Observable.create { observer in
            // 创建一个后台队列
            let queue = DispatchQueue.global(qos: .background)
            
            // 在后台队列中异步执行
            queue.async {
                var progress = 0
                
                // 循环更新进度直到100
                while progress < 100 {
                    progress += 5
                    observer.onNext(progress)
                    
                    // 使用睡眠来模拟操作耗时
                    Thread.sleep(forTimeInterval: 0.5)
                }
                
                // 发送完成信号
                observer.onCompleted()
            }
            
            // 返回Disposable
            return Disposables.create()
        }
    }
}




Manager.starCall{ progress in
    print("3-1当前进度: \(progress)%")
}
