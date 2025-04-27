import RxSwift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// 简单模拟外部事件源
class ExternalEventSource {
    // 定时产生事件，回调给观察者
    func beginProgressMonitoring(for observer: AnyObject, callback: @escaping (Int) -> Void) -> Void {
        // 开始监控进度，每秒发送一次
        print("外部系统：开始监控进度")
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            // 获取计时器已触发的次数
            let progress = timer.userInfo as? Int ?? 0
            callback(progress * 10)
            
            // 达到10次后停止
            if progress >= 10 {
                timer.invalidate()
                print("外部系统：进度监控完成")
            }
        }
        
        // 确保定时器在主线程上运行
        RunLoop.main.add(timer, forMode: .common)
    }
}

// 工具类
class Util {
    private let disposeBag = DisposeBag()
    private let externalSystem = ExternalEventSource()
    
    deinit {
        print("Util 被释放了！")
    }
    
    // 获取进度的Observable
    func getProgressObservable() -> Observable<Int> {
        return Observable<Int>.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            print("开始监听进度")
            
            // 使用self作为观察者，启动进度监控
            self.externalSystem.beginProgressMonitoring(for: self) { progress in
                observer.onNext(progress)
                
                if progress >= 100 {
                    observer.onCompleted()
                }
            }
            
            return Disposables.create {
                print("取消了进度监听")
            }
        }
    }
    
    // 启动进度监控（对外接口）
    func startMonitoring(callback: @escaping (Int) -> Void) {
        getProgressObservable()
            .subscribe(onNext: { progress in
                callback(progress)
            }, onCompleted: {
                print("进度监控完成")
            })
            .disposed(by: disposeBag)
    }
}

// 不正确的管理类（不保持引用）
class Manager {
    static func starCall(progressCallback: @escaping (Int) -> Void) {
        let util = Util() // 局部变量，方法结束后会被释放
        
        util.startMonitoring { progress in
            print("进度: \(progress)%")
        }
        
        print("Manager.startMonitoring 方法已执行完毕")
    }
}

Manager.starCall{ progress in
    print("当前进度: \(progress)%")
}
