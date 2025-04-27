//: A UIKit based Playground for presenting user interface
  
import RxSwift

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

import Foundation
import RxSwift
import RxCocoa

// 模拟硬件服务
class HardwareService {
    // 模拟检查设备是否开机
    func checkDevicePower() -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            print("正在检查设备电源状态...")
            // 模拟异步操作
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                let isPoweredOn = true // 模拟设备已开机
                print("设备电源状态: \(isPoweredOn ? "开机" : "关机")")
                observer.onNext(isPoweredOn)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    // 模拟发送连接指令
    func connectToDevice() -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            print("正在发送连接指令...")
            // 模拟连接过程
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
                let isConnected = true // 模拟连接成功
                print("设备连接状态: \(isConnected ? "已连接" : "连接失败")")
                observer.onNext(isConnected)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    // 模拟监听速度数据
    func monitorSpeedChanges() -> Observable<Double> {
        return Observable<Double>.create { observer in
            print("开始监听速度变化...")
            
            // 模拟每隔一段时间收到一次速度数据
            var speedValues = [12.5, 15.0, 18.2, 20.1, 17.8]
            var index = 0
            
            let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            timer.schedule(deadline: .now() + 1.0, repeating: 1.0)
            timer.setEventHandler {
                if index < speedValues.count {
                    let speed = speedValues[index]
                    observer.onNext(speed)
                    index += 1
                } else {
                    timer.cancel()
                    observer.onCompleted()
                }
            }
            timer.resume()
            
            return Disposables.create {
                timer.cancel()
            }
        }
    }
}

// 模拟网络服务
class NetworkService {
    // 检查WiFi是否可用
    func checkWiFiAvailability() -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            print("正在检查WiFi可用性...")
            // 模拟网络检查
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
                let isWiFiAvailable = true // 模拟WiFi可用
                print("WiFi状态: \(isWiFiAvailable ? "可用" : "不可用")")
                observer.onNext(isWiFiAvailable)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    // 检查蓝牙是否可用
    func checkBluetoothAvailability() -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            print("正在检查蓝牙可用性...")
            // 模拟蓝牙检查
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.2) {
                let isBluetoothAvailable = true // 模拟蓝牙可用
                print("蓝牙状态: \(isBluetoothAvailable ? "可用" : "不可用")")
                observer.onNext(isBluetoothAvailable)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}

// 硬件控制器
class HardwareController {
    private let hardwareService = HardwareService()
    private let networkService = NetworkService()
    private let disposeBag = DisposeBag()
    
    // 执行完整的设备连接和监控流程
    func startDeviceWorkflow() {
        print("开始设备工作流程...")
        
        // 1. 检查设备是否开机
        hardwareService.checkDevicePower()
            .filter { isPoweredOn in
                // 只有当设备开机时才继续
                return isPoweredOn
            }
            .flatMap { _ -> Observable<(Bool, Bool)> in
                // 2. 同时检查WiFi和蓝牙状态
                return Observable.combineLatest(
                    self.networkService.checkWiFiAvailability(),
                    self.networkService.checkBluetoothAvailability()
                )
            }
            .filter { wifiAvailable, bluetoothAvailable in
                // 3. 只有当WiFi和蓝牙都可用时才继续
                return wifiAvailable && bluetoothAvailable
            }
            .flatMap { _ -> Observable<Bool> in
                // 4. 发送连接指令
                return self.hardwareService.connectToDevice()
            }
            .filter { isConnected in
                // 只有当连接成功时才继续
                return isConnected
            }
            .flatMap { _ -> Observable<Double> in
                // 5. 连接成功后，监听速度变化
                return self.hardwareService.monitorSpeedChanges()
            }
            .subscribe(
                onNext: { speed in
                    // 处理接收到的速度数据
                    print("收到速度变化: \(speed) m/s")
                },
                onError: { error in
                    print("设备工作流程出错: \(error.localizedDescription)")
                }, onCompleted: {
                    print("设备工作流程已完成。")
                }
            )
            .disposed(by: disposeBag)
    }
}

// 主程序
func main() {
    let controller = HardwareController()
    controller.startDeviceWorkflow()
    
    // 让主线程等待，以便异步操作有时间完成
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 10))
}

// 运行主程序
main()
