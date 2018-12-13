//
//  drawing.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-20.

/*
 references
 “Core Graphics - How to Draw Heart Shape in UIView (IOS)? -.” 2015. Stack Overflow. 2015. https://stackoverflow.com/questions/29227858/how-to-draw-heart-shape-in-uiview-ios.
 
 Nguyen, Minh. 2017. “Building Your Own Chart in IOS — Part 2: Line Chart.” Medium. 2017. https://medium.com/@leonardnguyen/building-your-own-chart-in-ios-part-2-line-chart-7b5cfc7c866.

 */
//

import Foundation
import UIKit

extension UIBezierPath {
    convenience init(heartIn rect: CGRect) {
        self.init()
        
        let scaledWidth = (rect.size.width * 1.0)
        let scaledXValue = ((rect.size.width) - scaledWidth) / 2
        let scaledHeight = (rect.size.height * 1.0)
        let scaledYValue = ((rect.size.height) - scaledHeight) / 2
        
        let scaledRect = CGRect(x: scaledXValue, y: scaledYValue, width: scaledWidth, height: scaledHeight)
        
        self.move(to: CGPoint(x: rect.size.width/2, y: scaledRect.origin.y + scaledRect.size.height))
        
        
        self.addCurve(to: CGPoint(x: scaledRect.origin.x, y: scaledRect.origin.y + (scaledRect.size.height/4)),
                      controlPoint1:CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), y: scaledRect.origin.y + (scaledRect.size.height*3/4)) ,
                      controlPoint2: CGPoint(x: scaledRect.origin.x, y: scaledRect.origin.y + (scaledRect.size.height/2)) )
        
        self.addArc(withCenter: CGPoint( x: scaledRect.origin.x + (scaledRect.size.width/4),y: scaledRect.origin.y + (scaledRect.size.height/4)),
                    radius: (scaledRect.size.width/4),
                    startAngle: CGFloat(Double.pi),
                    endAngle: 0,
                    clockwise: true)
        
        self.addArc(withCenter: CGPoint( x: scaledRect.origin.x + (scaledRect.size.width * 3/4),y: scaledRect.origin.y + (scaledRect.size.height/4)),
                    radius: (scaledRect.size.width/4),
                    startAngle: CGFloat(Double.pi),
                    endAngle: 0,
                    clockwise: true)
        
        self.addCurve(to: CGPoint(x: rect.size.width/2, y: scaledRect.origin.y + scaledRect.size.height),
                      controlPoint1: CGPoint(x: scaledRect.origin.x + scaledRect.size.width, y: scaledRect.origin.y + (scaledRect.size.height/2)),
                      controlPoint2: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), y: scaledRect.origin.y + (scaledRect.size.height*3/4)) )
        
        self.close()
    }
    
    convenience init(dropIn rect: CGRect) {
        
        self.init()
        
        let topBubbleRadius = min(rect.size.width, rect.size.height)
        /// This magicValue helps to create 2 control points that can be used to draw a quater of a circle using Bezier curve function
        let magicValue: CGFloat = 0.552284749831 * topBubbleRadius
        let xPos = rect.origin.x
        let yPos = rect.origin.y
        
        //need to make all the paths the same
        //not sure this is a good way to get xpos and ypos but we'll see
        //also this is going to be upside down
        
        //top right side of the drop
        self.move(to: CGPoint(x: xPos, y: yPos)) // this is the left side middle point
        self.addCurve(to: CGPoint(x: xPos+topBubbleRadius, y: yPos-topBubbleRadius*1.5), controlPoint1: CGPoint(x: xPos, y: yPos-magicValue), controlPoint2: CGPoint(x: xPos+topBubbleRadius-magicValue, y: yPos-topBubbleRadius))
        //going to middle top there, want to start the other teardrop side
        //is that where I "am" or do I need to move there?
        self.addCurve(to: CGPoint(x: xPos+topBubbleRadius*2, y: yPos), controlPoint1: CGPoint(x: xPos+topBubbleRadius+magicValue, y: yPos-topBubbleRadius), controlPoint2: CGPoint(x: xPos+topBubbleRadius*2, y: yPos-magicValue))
        self.addArc(withCenter: CGPoint(x: xPos+topBubbleRadius, y: yPos), radius: -topBubbleRadius, startAngle: CGFloat(Double.pi),
                    endAngle: 0,
                    clockwise: true)
        
        self.close()
    }
    convenience init(arrowIn rect: CGRect) {
        self.init()
        
        self.move(to: CGPoint(x: rect.maxX, y: rect.minY)) // go to the rightmost, topmost corner
        self.addLine(to: CGPoint(x: rect.maxX, y:rect.maxY)) //draw a line down to the rightmost, bottommost corner
        self.addLine(to: CGPoint(x: rect.minX, y: rect.minY+(rect.height/2))) // draw a line to leftmost side, halfway up box
        self.addLine(to: CGPoint(x: rect.maxX, y: rect.minY)) // draw a line back to starting point
        
        self.close()
    }
}

extension Int {
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
}


