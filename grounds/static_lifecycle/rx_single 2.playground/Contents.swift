//: A UIKit based Playground for presenting user interface
  
import RxSwift

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

import RxSwift

// 管理类
class Manager {
    private var progressCallback: ((Int) -> Void)?
    private var util: Util?
    
    init(progressCallback: @escaping (Int) -> Void) {
        self.progressCallback = progressCallback
        
        // 创建Util实例
        self.util = Util()
        
        // 使用闭包方式检查状态并获取进度
        checkStatus()
    }
    
    private func checkStatus() {
        
        let util = Util()
        // 检查开机状态
        util.checkPowerStatusWithCallback { [weak self] isPowerOn in
            guard let self = self, isPowerOn else { return }
            
            // 检查WiFi状态
            self.util?.checkWiFiStatusWithCallback { isWiFiConnected in
                guard isWiFiConnected else { return }
                
                // 开始监听进度
                self.util?.observeProgressWithCallback { progress in
                    self.progressCallback?(progress)
                }
            }
        }
    }
}

// 工具类
class Util {
    private let disposeBag = DisposeBag()
    
    // 检查开机状态（使用闭包）
    func checkPowerStatusWithCallback(completion: @escaping (Bool) -> Void) {
        checkPowerStatus()
            .subscribe(onNext: { isPowerOn in
                completion(isPowerOn)
            })
            .disposed(by: disposeBag)
    }
    
    // 检查WiFi连接状态（使用闭包）
    func checkWiFiStatusWithCallback(completion: @escaping (Bool) -> Void) {
        checkWiFiStatus()
            .subscribe(onNext: { isWiFiConnected in
                completion(isWiFiConnected)
            })
            .disposed(by: disposeBag)
    }
    
    // 观察进度状态（使用闭包）
    func observeProgressWithCallback(progressCallback: @escaping (Int) -> Void) {
        observeProgress()
            .subscribe(onNext: { progress in
                progressCallback(progress)
            })
            .disposed(by: disposeBag)
    }
    
    // 以下是RxSwift实现的内部方法
    private func checkPowerStatus() -> Observable<Bool> {
        return Observable.just(true)  // 简化示例
    }
    
    private func checkWiFiStatus() -> Observable<Bool> {
        return Observable.just(true)  // 简化示例
    }
    
    private func observeProgress() -> Observable<Int> {
        return Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .map { Int($0 * 10) }
            .take(11)  // 0到100的进度
    }
}

// 使用示例
let manager = Manager { progress in
    print("当前进度: \(progress)%")
}
