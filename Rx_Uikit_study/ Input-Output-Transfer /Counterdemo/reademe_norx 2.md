/* 
三种非RxSwift的MVVM实现方式对比分析

以下是基于通知中心(NotificationCenter)、委托(Delegate)和KVO(Key-Value Observing)三种不同方式
实现MVVM模式的计数器应用的对比分析。
*/

// 1. 使用通知中心(NotificationCenter)
/*
优点:
- 多对多关系：一个发送者可以通知多个接收者，一个接收者可以从多个发送者接收通知
- 松耦合：发送者不需要知道接收者的存在
- 易于广播：全局事件通知简单

缺点:
- 类型安全差：通知和数据通过字符串和字典传递，容易出错
- 难以追踪：事件流不明确，调试困难
- 内存管理：需要手动移除观察者以避免内存泄漏
- 代码冗长：设置和处理通知需要大量样板代码
*/

// NotificationCenter示例代码片段
// 在ViewModel中:
NotificationCenter.default.post(
    name: CounterViewModel.counterTextDidChangeNotification,
    object: self,
    userInfo: ["text": "当前计数: \(counter)"]
)

// 在ViewController中:
NotificationCenter.default.addObserver(
    self,
    selector: #selector(counterTextDidChange),
    name: CounterViewModel.counterTextDidChangeNotification,
    object: viewModel
)

@objc private func counterTextDidChange(notification: Notification) {
    if let text = notification.userInfo?["text"] as? String {
        counterLabel.text = text
    }
}


// 2. 使用委托(Delegate)
/*
优点:
- 类型安全：协议明确定义了方法和参数类型
- 明确的一对一关系：清晰的通信路径
- 编译时检查：协议方法实现在编译时验证
- 强力的接口约束：明确定义了通信接口

缺点:
- 一对一关系：一个ViewModel只能有一个delegate
- 紧耦合：ViewModel需要持有delegate引用
- 接口膨胀：随着功能增加，协议方法可能变得臃肿
- 代码量：需要定义和实现协议
*/

// Delegate示例代码片段
// 定义协议:
protocol CounterViewModelDelegate: AnyObject {
    func counterViewModel(_ viewModel: CounterViewModel, didUpdateCounterText text: String)
    func counterViewModel(_ viewModel: CounterViewModel, didUpdateCanDecrement canDecrement: Bool)
}

// 在ViewModel中:
weak var delegate: CounterViewModelDelegate?

// 发送事件:
delegate?.counterViewModel(self, didUpdateCounterText: getCounterText())

// 在ViewController中:
func counterViewModel(_ viewModel: CounterViewModel, didUpdateCounterText text: String) {
    counterLabel.text = text
}


// 3. 使用KVO(Key-Value Observing)
/*
优点:
- 内置于Objective-C运行时：无需额外框架
- 属性级监听：可以精确观察特定属性
- 自动触发：属性更改自动通知
- 功能强大：可以观察对象图中深层嵌套的属性变化

缺点:
- 需要NSObject：被观察类需要继承NSObject
- 运行时机制：依赖Objective-C运行时，不是纯Swift解决方案
- 字符串键路径：早期KVO使用字符串键，容易出错
- 可能的性能影响：基于运行时机制，可能比其他方法开销大
- 生命周期管理：需要手动管理观察者的生命周期
*/

// KVO示例代码片段
// 在ViewModel中:
@objc dynamic private(set) var counter: Int = 0

// 在ViewController中:
let textObservation = viewModel.observe(\.counterText, options: [.initial, .new]) { [weak self] (viewModel, change) in
    guard let self = self, let newValue = change.newValue else { return }
    self.counterLabel.text = newValue
}


// 各种实现方式与RxSwift对比
/*
使用RxSwift的优势:
1. 声明式：更加关注"发生了什么"而非"如何做"
2. 组合能力强：使用操作符可以方便地组合和转换事件流
3. 统一抽象：Observable统一了异步事件处理
4. 线程管理：内置的调度器简化了线程切换
5. 取消操作：DisposeBag机制简化了资源管理
6. 错误处理：链式错误传播和恢复机制
7. 避免回调地狱：扁平化的异步代码

常规MVVM实现的优势:
1. 无第三方依赖：使用系统框架实现，无需引入额外库
2. 学习曲线平缓：使用熟悉的Swift/UIKit概念
3. 对简单UI足够：对于简单应用可能更直接
4. 调试简单：传统调试技术适用
5. 团队适应性：新团队成员更容易理解
*/

// 使用场景建议
/*
推荐使用RxSwift的场景:
- 复杂的异步操作链
- 多个相互依赖的UI状态
- 需要处理多个数据源
- 表单验证和实时响应
- 复杂的网络请求流程
- 依赖于时间的操作

推荐使用传统MVVM的场景:
- 简单的数据展示
- 团队对RxSwift不熟悉
- 项目规模小，不想引入依赖
- 关注应用大小和编译时间
- 学习项目，需要理解基础概念
*/

// 总结
/*
三种传统实现各有优缺点:

- NotificationCenter: 适合多对多关系，但类型安全性差
- Delegate: 类型安全且接口清晰，但只支持一对一关系
- KVO: 无需额外代码就能监听属性变化，但需要NSObject支持

RxSwift提供了这三种方法的优点，同时避免了它们的大部分缺点，但代价是引入了学习成本和依赖。

理想的选择取决于项目的具体需求、团队的技术背景和长期维护考虑。
*/
