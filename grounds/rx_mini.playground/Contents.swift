//: A UIKit based Playground for presenting user interface
  
import RxSwift

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// 创建 DisposeBag 管理订阅生命周期
let disposeBag = DisposeBag()

// 创建 Observable，发出 1, 2, 3 然后完成
let observable = Observable<Int>.create { observer in
    observer.onNext(1)
    observer.onNext(2)
    observer.onNext(3)
    observer.onCompleted()
    return Disposables.create{
        print("释放")
    }
}

// 订阅 Observable
observable.subscribe(
    onNext: { value in
        print("Received value: \(value)")
    },
    onCompleted: {
        print("Completed")
    }
).disposed(by: disposeBag)

