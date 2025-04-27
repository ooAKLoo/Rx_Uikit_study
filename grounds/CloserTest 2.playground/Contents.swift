//: A UIKit based Playground for presenting user interface
  
import RxSwift

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


let add: (Int, Int) -> Int = { n1,n2 in
    return n1+n2
}

print(add(1,2))

let numbers = [5, 3, 8, 2, 1, 9, 4]

let sort = { (nums: [Int]) -> [Int] in
    return nums.sorted()
    
}

print(sort(numbers))
print(numbers.filter{$0 % 2 == 0})

print(numbers.map{$0*2})

func f1() -> (Int) -> Int{
    return { num in
        return num*num
    }
}

print(f1()(2))

var num=1
let counter = {
    num = num + 1
    return num
}

print(counter())
print(counter())

func f2(s:String,closer1:(String) -> String, closer2: (String) -> Bool) -> Bool{
    return closer2(closer1(""))
}


let c1 = { (s:String) in
    return "prex_"+s
}
print(f2(s:"hello",closer1: c1){ s in
        return s.contains("prex")
    })



func f3() -> Int{
    1 //swift语法糖
}

func f4() -> Int{
    return 1
}

//func f5() -> Int{
//
//}

print("f3",f3())
