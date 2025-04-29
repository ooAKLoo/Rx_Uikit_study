////
////  ExternalEventSource-Problem.swift
////  Rx_Uikit_study
////
//
//import UIKit
//import RxSwift
//
//// 简单模拟外部事件源
//class ExternalEventSource {
//    private var taskIdentifier = 0
//    
//    func beginProgressMonitoring(for observer: AnyObject, callback: @escaping (Int) -> Void) -> Int {
//        taskIdentifier += 1
//        let currentTaskId = taskIdentifier
//        
//        print("外部系统[\(currentTaskId)]：开始监控进度")
//        
//        var currentProgress = 0
//        
//        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//            callback(currentProgress)
//            currentProgress += 10
//            
//            if currentProgress > 100 {
//                timer.invalidate()
//                print("外部系统[\(currentTaskId)]：进度监控完成")
//            }
//        }
//        
//        RunLoop.main.add(timer, forMode: .common)
//        return currentTaskId
//    }
//}
//
//// 工具类
//class Util {
//    private let externalSystem = ExternalEventSource()
//    private let instanceId = UUID().uuidString.prefix(6)
//    
//    init() {
//        print("Util[\(instanceId)] 被初始化")
//    }
//    
//    deinit {
//        print("Util[\(instanceId)] 被释放")
//    }
//    
//    // 将进度作为Observable返回
//    func getProgressObservable() -> Observable<Int> {
//        return Observable<Int>.create { [weak self] observer in
//            guard let self = self else {
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            print("Util[\(self.instanceId)] 开始监听进度")
//            
//            // 开始监控进度
//            let taskId = self.externalSystem.beginProgressMonitoring(for: self) { progress in
//                print("Util[\(self.instanceId)] 收到进度: \(progress)%")
//                observer.onNext(progress)
//                
//                if progress >= 100 {
//                    observer.onCompleted()
//                }
//            }
//            
//            return Disposables.create {
//                print("Util[\(self.instanceId)] 的任务[\(taskId)]取消订阅")
//            }
//        }
//    }
//    
//    func startMonitoring() -> Observable<Int> {
//        return getProgressObservable()
//    }
//}
//
//// 管理类
//class Manager {
//    private static var util: Util? // 静态变量保存工具实例
//    private static var disposeBag = DisposeBag() // 静态DisposeBag管理订阅
//    private static var callCount = 0 // 跟踪调用次数
//    
//    static func startMonitoring(progressCallback: @escaping (Int) -> Void, completion: @escaping () -> Void) {
//        callCount += 1
//        let currentCall = callCount
//        
//        print("Manager.startMonitoring[\(currentCall)] 开始执行")
//        
//        // 创建并保存工具实例
//        util = Util()
//        
//        let subscription = util?.startMonitoring()
//            .subscribe(onNext: { progress in
//                print("Manager回调[\(currentCall)]: \(progress)%")
//                progressCallback(progress)
//            }, onCompleted: {
//                print("Manager.onCompleted[\(currentCall)] 被调用")
//                completion()
//                util = nil // 完成后释放工具实例
//            })
//        
//        subscription?.disposed(by: disposeBag)
//        print("Manager.startMonitoring[\(currentCall)] 已执行完毕，当前DisposeBag中有约\(disposeBag)个订阅")
//    }
//    
//    // 添加一个方法显示DisposeBag的当前状态
//    static func printDisposeBagStatus() {
//        print("当前DisposeBag状态: \(disposeBag.self)")
//    }
//    
//    // 添加一个方法来重置DisposeBag
//    static func resetDisposeBag() {
//        print("正在重置DisposeBag...")
//        disposeBag = DisposeBag()
//        print("DisposeBag已重置")
//    }
//}
//
//// 视图控制器
//class ProgressViewController: UIViewController {
//    private var progressView: UIProgressView!
//    private var counterLabel: UILabel!
//    private var callCount = 0
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // 创建进度条
//        progressView = UIProgressView(progressViewStyle: .default)
//        progressView.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 20)
//        progressView.progress = 0.0
//        view.addSubview(progressView)
//        
//        // 创建计数器标签
//        counterLabel = UILabel(frame: CGRect(x: 20, y: 130, width: view.frame.width - 40, height: 30))
//        counterLabel.text = "点击次数: 0"
//        counterLabel.textAlignment = .center
//        view.addSubview(counterLabel)
//        
//        // 创建开始按钮
//        let startButton = UIButton(type: .system)
//        startButton.setTitle("开始监控", for: .normal)
//        startButton.addTarget(self, action: #selector(startMonitoring), for: .touchUpInside)
//        startButton.frame = CGRect(x: 20, y: 180, width: (view.frame.width - 60) / 2, height: 50)
//        view.addSubview(startButton)
//        
//        // 创建重置按钮
//        let resetButton = UIButton(type: .system)
//        resetButton.setTitle("重置DisposeBag", for: .normal)
//        resetButton.addTarget(self, action: #selector(resetDisposeBag), for: .touchUpInside)
//        resetButton.frame = CGRect(x: view.frame.width/2 + 10, y: 180, width: (view.frame.width - 60) / 2, height: 50)
//        view.addSubview(resetButton)
//        
//        // 添加内存警告监听
//        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
//    }
//    
//    @objc func startMonitoring() {
//        callCount += 1
//        counterLabel.text = "点击次数: \(callCount)"
//        
//        print("\n=== 开始第\(callCount)次监控 ===")
//        
//        progressView.progress = 0.0 // 重置进度条
//        
//        Manager.startMonitoring(progressCallback: { [weak self] progress in
//            guard let self = self else { return }
//            
//            let progressValue = Float(progress) / 100.0
//            self.progressView.setProgress(progressValue, animated: true)
//        }, completion: {
//            print("视图控制器：第\(self.callCount)次进度监控完成")
//            print("===== 完成 =====\n")
//            
//            // 打印当前DisposeBag状态
//            Manager.printDisposeBagStatus()
//        })
//    }
//    
//    @objc func resetDisposeBag() {
//        Manager.resetDisposeBag()
//    }
//    
//    @objc override func didReceiveMemoryWarning() {
//        print("⚠️ 收到内存警告！可能存在内存泄漏")
//    }
//    
//    deinit {
//        print("ProgressViewController被释放")
//        NotificationCenter.default.removeObserver(self)
//    }
//}
