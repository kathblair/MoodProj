//
//  sorting.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-13.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import Foundation

func timesort(one: AnyObject, two: AnyObject)->Bool {
    // this sorting is kinda working, but the resulting info is pretty cray.
    
    if let t1 = one["time"], let t1a = t1, let t2 = two["time"], let t2a = t2 {
        
        let tt1 = t1a as! Double
        let tt2 = t2a as! Double
        
        return tt1 > tt2
        /*
         if(tt1 > tt2){
         // first time is further in the future than the last time
         print("\(tt1) is greater than \(tt2) so return TRUE")
         re_urn true
         }else{
         print("\(tt1) is less than \(tt2) so return FALSE")
         return false
         }*/
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
