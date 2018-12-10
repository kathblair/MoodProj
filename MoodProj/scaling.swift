//
//  scaling.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-13.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import Foundation
import QuartzCore

struct Rescale<Type : BinaryFloatingPoint> {
    typealias RescaleDomain = (lowerBound: Type, upperBound: Type)
    
    var fromDomain: RescaleDomain
    var toDomain: RescaleDomain
    
    init(from: RescaleDomain, to: RescaleDomain) {
        self.fromDomain = from
        self.toDomain = to
    }
    
    func interpolate(_ x: Type ) -> Type {
        return self.toDomain.lowerBound * (1 - x) + self.toDomain.upperBound * x;
    }
    
    func uninterpolate(_ x: Type) -> Type {
        let b = (self.fromDomain.upperBound - self.fromDomain.lowerBound) != 0 ? self.fromDomain.upperBound - self.fromDomain.lowerBound : 1 / self.fromDomain.upperBound;
        return (x - self.fromDomain.lowerBound) / b
    }
    
    func rescale(_ x: Type )  -> Type {
        return interpolate( uninterpolate(x) )
    }
}

extension CGFloat {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
        let result = ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
        return result
    }
}

extension Double {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> Double {
        return Double(CGFloat(self).map(from: from, to: to))
    }
}

extension Float {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> Float {
        return Float(CGFloat(self).map(from: from, to: to))
    }
}
