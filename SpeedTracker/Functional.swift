//
//  Functional.swift
//  SpeedTracker
//
//  Created by Rafael Almeida on 23/07/15.
//  Copyright (c) 2015 ISWE. All rights reserved.
//

import Foundation

infix operator >>> { associativity left }

func >>> <A, B, C>(f: B -> C, g: A -> B) -> A -> C {
    return { x in f(g(x)) }
}

class Functional {
    
    class func curry<A, B, C>(f: (A, B) -> C) -> A -> B -> C {
        return { a in { b in f(a, b) } }
    }
    
}