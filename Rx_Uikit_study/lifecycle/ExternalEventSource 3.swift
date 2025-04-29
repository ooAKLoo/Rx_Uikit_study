////
////  ExternalEventSource 3.swift
////  Rx_Uikit_study
////
////  Created by 杨东举 on 2025/4/27.
////
//
//
//import UIKit
//import RxSwift
//
//// Simple simulation of an external event source
//class ExternalEventSource {
//    func beginProgressMonitoring(for observer: AnyObject, callback: @escaping (Int) -> Void) -> Void {
//        print("外部系统：开始监控进度")
//        
//        var currentProgress = 0 // Track progress with a local variable
//        
//        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//            callback(currentProgress) // Pass current progress via callback
//            currentProgress += 10     // Increment by 10
//            
//            if currentProgress > 100 { // Stop when progress reaches 100
//                timer.invalidate()
//                print("外部系统：进度监控完成")
//            }
//        }
//        
//        RunLoop.main.add(timer, forMode: .common)
//    }
//}
//
//// Utility class
//class Util {
//    private let externalSystem = ExternalEventSource()
//    
//    deinit {
//        print("Util 被释放了！")
//    }
//    
//    // Get progress as an Observable
//    func getProgressObservable() -> Observable<Int> {
//        return Observable<Int>.create { [weak self] observer in
//            guard let self = self else {
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            print("开始监听进度")
//            
//            // Start progress monitoring with self as the observer
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
//    func startMonitoring() -> Observable<Int> {
//        return getProgressObservable()
//    }
//}
//
//// Management class
//class Manager {
//    private static var util: Util? // Static variable to hold util instance
//    private static var disposeBag = DisposeBag() // Static disposeBag to manage subscriptions
//    
//    static func startMonitoring(progressCallback: @escaping (Int) -> Void, completion: @escaping () -> Void) {
//        // Create and hold util instance
//        util = Util()
//        
//        util?.startMonitoring()
//            .subscribe(onNext: { progress in
//                progressCallback(progress)
//            }, onCompleted: {
//                completion()
//                util = nil // Release util after completion
//            })
//            .disposed(by: disposeBag)
//        
//        print("Manager.startMonitoring 方法已执行完毕")
//    }
//}
//
//// View controller
//class ProgressViewController: UIViewController {
//    private var progressView: UIProgressView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Create progress bar
//        progressView = UIProgressView(progressViewStyle: .default)
//        progressView.frame = CGRect(x: 20, y: 100, width: 300, height: 20)
//        progressView.progress = 0.0
//        view.addSubview(progressView)
//        
//        // Create button
//        let button = UIButton(type: .system)
//        button.setTitle("Start Monitoring", for: .normal)
//        button.addTarget(self, action: #selector(startMonitoring), for: .touchUpInside)
//        button.frame = CGRect(x: 100, y: 150, width: 200, height: 50)
//        view.addSubview(button)
//    }
//    
//    @objc func startMonitoring() {
//        Manager.startMonitoring(progressCallback: { [weak self] progress in
//            let progressValue = Float(progress) / 100.0
//            self?.progressView.setProgress(progressValue, animated: true)
//            print("当前进度: \(progress)%")
//        }, completion: {
//            print("进度监控完成")
//        })
//    }
//}
