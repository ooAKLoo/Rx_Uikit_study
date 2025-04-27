//: A UIKit based Playground for presenting user interface
  
import RxSwift

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


let add: (Int,Int) -> Int = {(num1, num2) in
    return num1 + num2
}

let add1: (Int,Int) -> Int = {(num1, num2) in num1 + num2}

let add2: (Int,Int) -> Int = {$0 + $1}


print(add(3,4))
print(add1(3,4))
print(add2(3,4))

let noPara = {
    print("hello")
}

noPara()

func applyClosure(_ num: Int, completion: (Int) -> Int) -> Int{
    return completion(num)
}

let double: (Int) -> Int = {$0 * 4}
let num=10
print(applyClosure(num, completion: { Int in
    Int * 2
}))
print(applyClosure(num, completion: double))


print(applyClosure(num){$0 * 3})

var vari:Int = 1
let closer:() -> Int = {
    vari = vari + 1
    return vari
}

print("vari",closer())
print("vari",closer())


func returnCloser() -> (String) -> String{
    return { (s:String) -> String in
        return "prefix"+s
    }
}

print(returnCloser()("www"))

func performAsyncTask(closer: @escaping () -> Void) -> Int{
    print(1)
    DispatchQueue.global().async{
        sleep(1)
            closer()
    }
    print(2)
    return 4
}

print(performAsyncTask {
    print("逃逸3")
})


var value1 = 10
let closure1: () -> Void = { [value1] in
    var value1 = value1
    value1 += 1
    print("Inside closure: \(value1)")
}

var value2 = 10
let closure2: () -> Void = {
    value2 += 1
    print("Inside closure: \(value2)")
}

closure1()
print("Outside closure: \(value1)")  // 输出 Outside closure: 10
closure2()
print("Outside closure: \(value2)")  // 输出 Outside closure: 10


let numbers = [1, 2, 3, 4, 5]

let x = numbers.map{$0*2}
print(x)


