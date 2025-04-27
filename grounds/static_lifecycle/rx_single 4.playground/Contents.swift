//: A UIKit based Playground for presenting user interface

import RxSwift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// 管理类
class Manager {
    
    static func starCall(progressCallback: @escaping (Int) -> Void){
        let util = Util()
        util.startMonitoringProgress(progressCallback: progressCallback)
    }
}

import RxSwift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// 模拟网络API
class NetworkAPI {
    // 模拟获取进度的网络请求
    static func fetchProgress(currentProgress: Int, completion: @escaping (Int) -> Void) {
        // 模拟网络延迟
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // 返回新的进度值（每次增加10%）
            let newProgress = min(currentProgress + 10, 100)
            
            // 在主线程回调
            DispatchQueue.main.async {
                completion(newProgress)
            }
        }
    }
}


// 工具类
class Util {
    private let disposeBag = DisposeBag()
    private var timer: Timer?
    
    // 初始化器
    init() {
        print("⭐ Util 被初始化")
    }
    
    // 析构器
    deinit {
        print("❌ Util 被释放")
    }
    
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
        return Observable<Int>.create { observer in
            print("开始通过网络API监控进度")
            
            // 初始值为0
            observer.onNext(0)
            
            // 递归函数来获取下一个进度值
            NetworkAPI.fetchProgress(currentProgress: 0) { newProgress in
                observer.onNext(newProgress)
                
                if newProgress < 100 {
                    // 继续获取下一个进度值
                   
                } else {
                    // 进度完成
                    observer.onCompleted()
                }
            }
            
            
            return Disposables.create {
                print("取消进度监控")
            }
        }
    }
}

// 使用示例

Manager.starCall{ progress in
    print("当前进度: \(progress)%")
}

