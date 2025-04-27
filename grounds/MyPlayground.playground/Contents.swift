//: A UIKit based Playground for presenting user interface
  
import RxSwift

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


let numbers = [1, 2, 3, 4, 5]

let x = numbers.map{$0*2}
print(numbers.filter{$0 % 2 == 0})


