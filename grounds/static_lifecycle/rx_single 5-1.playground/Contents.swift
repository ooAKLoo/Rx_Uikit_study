import RxSwift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// 简单模拟外部事件源
class ExternalEventSource {
    func beginProgressMonitoring(for observer: AnyObject, callback: @escaping (Int) -> Void) -> Void {
        print("外部系统：开始监控进度")
        
        var currentProgress = 0 // 使用局部变量追踪进度
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            callback(currentProgress) // 调用 callback，传递当前进度
            currentProgress += 10     // 每次增加10
            
            if currentProgress >= 100 { // 当进度达到100时停止
                timer.invalidate()
                print("外部系统：进度监控完成")
            }
        }
        
        RunLoop.main.add(timer, forMode: .common)
    }
}

//// 示例用法：假设在一个类中调用
//class TestClass {
//    func startMonitoring() {
//        let source = ExternalEventSource()
//        source.beginProgressMonitoring(for: self, callback: { progress in
//            print("当前进度: \(progress)%")
//        })
//    }
//}
//
//// 测试调用
//let test = TestClass()
//test.startMonitoring()
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
    //    func startMonitoring(callback: @escaping (Int) -> Void) {
    //        getProgressObservable()
    //            .subscribe(onNext: { progress in
    //                callback(progress)
    //            }, onCompleted: {
    //                print("进度监控完成")
    //            })
    //            .disposed(by: disposeBag)
    //    }
    
    func startMonitoring() -> Observable<Int> {
        return getProgressObservable()
    }
}

// 不正确的管理类（不保持引用）
class Manager {
    static func starCall(progressCallback: @escaping (Int) -> Void) {
        let util = Util() // 局部变量，方法结束后会被释放
        
        //        util.startMonitoring { progress in
        //            print("进度: \(progress)%")
        //        }
        let dis = util.startMonitoring()
            .subscribe(onNext: { progress in
                progressCallback(progress)
            }, onCompleted: {
                print("进度监控完成")
            })
        
        print("Manager.startMonitoring 方法已执行完毕")
    }
}

Manager.starCall{ progress in
    print("当前进度: \(progress)%")
}
