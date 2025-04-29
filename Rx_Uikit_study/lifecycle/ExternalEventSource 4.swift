////
////  ExternalEventSource 4.swift
////  Rx_Uikit_study
////
////  Created by 杨东举 on 2025/4/27.
////
//
//import UIKit
//import RxSwift
//
//// 外部事件源保持不变
//class ExternalEventSource {
//    func beginProgressMonitoring(for observer: AnyObject, callback: @escaping (Int) -> Void) -> Void {
//        print("外部系统：开始监控进度")
//        
//        var currentProgress = 0 // 使用局部变量跟踪进度
//        
//        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//            callback(currentProgress) // 通过回调传递当前进度
//            currentProgress += 10     // 增加10
//            
//            if currentProgress > 100 { // 当进度达到100时停止
//                timer.invalidate()
//                print("外部系统：进度监控完成")
//            }
//        }
//        
//        RunLoop.main.add(timer, forMode: .common)
//    }
//}
//
//// 工具类改为单例，内部使用RxSwift
//class Util {
//    // 单例实例
//    static let shared = Util()
//    
//    // 私有化初始化方法，防止外部创建
//    private init() {
//        print("Util 单例被初始化")
//    }
//    
//    private let externalSystem = ExternalEventSource()
//    
//    // 内部使用的DisposeBag
//    private var disposeBag = DisposeBag()
//    
//    deinit {
//        print("Util 被释放了！") // 单例下不会调用，但保留以便日后修改
//    }
//    
//    // 内部方法：获取进度Observable
//    private func getProgressObservable() -> Observable<Int> {
//        return Observable<Int>.create { [weak self] observer in
//            guard let self = self else {
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            print("开始监听进度")
//            
//            // 开始监控进度
//            self.externalSystem.beginProgressMonitoring(for: self) { progress in
//                observer.onNext(progress)
//                
//                if progress >= 100 {
//                    observer.onCompleted()
//                }
//            }
//            
//            return Disposables.create {
//                print("取消了进度监听")
//            }
//        }
//    }
//    
//    // 外部接口：使用闭包而非返回Observable
//    func startMonitoring(progressCallback: @escaping (Int) -> Void, completion: @escaping () -> Void) {
//        // 每次开始监控前清空DisposeBag
//        disposeBag = DisposeBag()
//        
//        // 内部使用RxSwift
//        getProgressObservable()
//            .subscribe(onNext: { progress in
//                progressCallback(progress)
//            }, onCompleted: {
//                completion()
//            })
//            .disposed(by: disposeBag)
//    }
//}
//
//// 管理类
//class Manager {
//    // 不再需要静态util变量和disposeBag
//    
//    static func startMonitoring(progressCallback: @escaping (Int) -> Void, completion: @escaping () -> Void) {
//        // 直接使用单例
//        Util.shared.startMonitoring(
//            progressCallback: progressCallback,
//            completion: completion
//        )
//        
//        print("Manager.startMonitoring 方法已执行完毕")
//    }
//}
//
//// 视图控制器
//class ProgressViewController: UIViewController {
//    private var progressView: UIProgressView!
//    private var statusLabel: UILabel!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        
//        // 创建进度条
//        progressView = UIProgressView(progressViewStyle: .default)
//        progressView.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 20)
//        progressView.progress = 0.0
//        view.addSubview(progressView)
//        
//        // 创建状态标签
//        statusLabel = UILabel(frame: CGRect(x: 20, y: 130, width: view.frame.width - 40, height: 30))
//        statusLabel.text = "准备就绪"
//        statusLabel.textAlignment = .center
//        view.addSubview(statusLabel)
//        
//        // 创建开始按钮
//        let startButton = UIButton(type: .system)
//        startButton.setTitle("开始监控", for: .normal)
//        startButton.addTarget(self, action: #selector(startMonitoring), for: .touchUpInside)
//        startButton.frame = CGRect(x: 50, y: 180, width: 120, height: 50)
//        view.addSubview(startButton)
//    }
//    
//    @objc func startMonitoring() {
//        progressView.progress = 0.0
//        statusLabel.text = "正在监控..."
//        
//        Manager.startMonitoring(progressCallback: { [weak self] progress in
//            guard let self = self else { return }
//            
//            let progressValue = Float(progress) / 100.0
//            self.progressView.setProgress(progressValue, animated: true)
//            self.statusLabel.text = "当前进度: \(progress)%"
//            print("当前进度: \(progress)%")
//        }, completion: { [weak self] in
//            guard let self = self else { return }
//            
//            self.statusLabel.text = "监控完成"
//            print("进度监控完成")
//        })
//    }
//    
//    deinit {
//        print("ProgressViewController 被释放")
//    }
//}
