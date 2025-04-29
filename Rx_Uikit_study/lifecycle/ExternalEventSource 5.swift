//
//  ExternalEventSource 5.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/4/28.
//


//
//  ExternalEventSource 2.swift
//  Rx_Uikit_study
//
//  Created by 杨东举 on 2025/4/27.
//

import UIKit
import RxSwift

// 简单模拟外部事件源
class ExternalEventSource {
    func beginProgressMonitoring(for observer: AnyObject, callback: @escaping (Int) -> Void) -> Void {
        print("外部系统：开始监控进度")
        
        var currentProgress = 0 // 使用局部变量追踪进度
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            callback(currentProgress) // 调用 callback，传递当前进度
            currentProgress += 10     // 每次增加10
            
            if currentProgress > 100 { // 当进度达到100时停止
                timer.invalidate()
                print("外部系统：进度监控完成")
            }
        }
        
        RunLoop.main.add(timer, forMode: .common)
    }
}

// 工具类
class Util {
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
    
    // 修改为返回Disposable
    func startMonitoring(progressCallback: @escaping (Int) -> Void, completion: @escaping () -> Void) -> Disposable {
        let subscription = getProgressObservable()
            .subscribe(onNext: { progress in
                progressCallback(progress)
            }, onCompleted: {
                completion()
            })
        
        return subscription
    }
}

// 管理类
class Manager {
    // 移除静态disposeBag
    static func startMonitoring(util: Util, progressCallback: @escaping (Int) -> Void, completion: @escaping () -> Void) -> Disposable {
        // 返回Disposable供调用者处理
        let disposable = util.startMonitoring(progressCallback: progressCallback, completion: completion)
        print("Manager.startMonitoring 方法已执行完毕")
        return disposable
    }
}

// 视图控制器
class ProgressViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private var util: Util? = Util() // 可选类型
    private var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建进度条
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.frame = CGRect(x: 20, y: 100, width: 300, height: 20)
        progressView.progress = 0.0
        view.addSubview(progressView)
        
        // 创建按钮
        let button = UIButton(type: .system)
        button.setTitle("Start Monitoring", for: .normal)
        button.addTarget(self, action: #selector(startMonitoring), for: .touchUpInside)
        button.frame = CGRect(x: 100, y: 150, width: 200, height: 50)
        view.addSubview(button)
    }
    
    @objc func startMonitoring() {
        guard let currentUtil = util else { return }
        
        // 使用currentUtil而非强制解包
        let disposable = Manager.startMonitoring(util: currentUtil, progressCallback: { [weak self] progress in
            let progressValue = Float(progress) / 100.0
            self?.progressView.setProgress(progressValue, animated: true)
            print("当前进度: \(progress)%")
        }, completion: { [weak self] in
            print("进度监控完成")
            self?.util = nil
        })
        
        // 将返回的Disposable添加到视图控制器的disposeBag中
        disposable.disposed(by: disposeBag)
    }
}