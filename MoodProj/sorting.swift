//
//  sorting.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-13.
//

import Foundation

func timesort(one: AnyObject, two: AnyObject)->Bool {
    
    if let t1 = one["time"], let t1a = t1, let t2 = two["time"], let t2a = t2 {
        
        let tt1 = t1a as! Double
        let tt2 = t2a as! Double
        
        return tt1 > tt2
    } else {
        return false
    }
    
}

func reversetimesort(one: AnyObject, two: AnyObject)->Bool {
    
    if let t1 = one["time"], let t1a = t1, let t2 = two["time"], let t2a = t2 {
        
        let tt1 = t1a as! Double
        let tt2 = t2a as! Double
        
        return tt1 < tt2 //-- for backwards sorting
    } else {
        return false
    }
    
}

func uniqueRandoms(numberOfRandoms: Int, minNum: Int, maxNum: UInt32) -> [Int] {
    var uniqueNumbers = Set<Int>()
    while uniqueNumbers.count < numberOfRandoms {
        uniqueNumbers.insert(Int(arc4random_uniform(maxNum + 1)) + minNum)
    }
    return Array(uniqueNumbers).shuffled()
}
