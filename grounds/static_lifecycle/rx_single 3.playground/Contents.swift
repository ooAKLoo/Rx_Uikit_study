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
    private var util: Util?
    
//    init(progressCallback: @escaping (Int) -> Void) {
//        self.util = Util()
//    }
    
    init() {
        self.util = Util()
    }
    
    func starCall(progressCallback: @escaping (Int) -> Void){
        let util = Util()
        util.startMonitoringProgress(progressCallback: progressCallback)
    }
}

// 工具类
class Util {
    private let disposeBag = DisposeBag()
    
    // 启动进度监控（唯一暴露的接口）
    func startMonitoringProgress(progressCallback: @escaping (Int) -> Void) {
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
        return Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .map { Int($0 * 10) }
            .take(11)  // 0到100的进度
    }
}

// 使用示例
//let manager = Manager { progress in
//    print("当前进度: \(progress)%")
//}

let manager = Manager()
manager.starCall{ progress in
        print("当前进度: \(progress)%")
    }
