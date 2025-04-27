//: A UIKit based Playground for presenting user interface
  
import RxSwift

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

import RxSwift

// 管理类
@objc class Manager:NSObject {
    private let disposeBag = DisposeBag()
    
    init(progressCallback: @escaping (Int) -> Void) {
        // 调用工具方法，创建Util实例而非使用单例
        let util = Util()
        
        // 检查开机和WiFi状态，并监听进度
        util.checkPowerStatus()
            .filter { $0 } // 只有开机状态为true时继续
            .flatMap { _ in util.checkWiFiStatus() }
            .filter { $0 } // 只有WiFi连接状态为true时继续
            .flatMap { _ in util.observeProgress() }
            .subscribe(onNext: progressCallback)
            .disposed(by: disposeBag)
    }
}

// 工具类
class Util {
    private let disposeBag = DisposeBag()
    
    // 检查开机状态
    func checkPowerStatus() -> Observable<Bool> {
        return Observable.just(true)  // 简化示例
    }
    
    // 检查WiFi连接状态
    func checkWiFiStatus() -> Observable<Bool> {
        return Observable.just(true)  // 简化示例
    }
    
    // 观察进度状态
    func observeProgress() -> Observable<Int> {
        return Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .map { Int($0 * 10) }
            .take(11)  // 0到100的进度
    }
}

// 使用示例
let manager = Manager { progress in
    print("当前进度: \(progress)%")
}
