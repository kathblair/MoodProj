//
//  drawing.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-20.
/*references

 Begbie, Caroline. 2018. “Drawing in IOS · Custom Control.” Raywenderlich.Com. 2018. https://www.raywenderlich.com/4659-drawing-in-ios/lessons/5.
 */
//

import Foundation
import UIKit


@IBDesignable
class ThermometerView: UIView {
    let thermoLayer = CAShapeLayer()
    let levelLayer = CAShapeLayer()
    let maskLayer = CAShapeLayer()
    @IBInspectable var level: CGFloat = 0.5 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var lineWidth: CGFloat{
        return bounds.width/4
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        buildLevelLayer()
    }
    
    private func setup() {
        // make it so I can just use bounds like a reasonable person
        self.layer.addSublayer(thermoLayer)
        self.layer.addSublayer(levelLayer)
        //print(screenWidth)
        //could I pass this? or set it if there are bounds?
        //self.layer.borderColor = UIColor.blue.cgColor
        //self.layer.borderWidth = 1
        
        drawContents()
    }
    
    public func drawContents() {
        thermoLayer.frame = CGRect(x: 0, y:0, width:self.bounds.width, height: self.bounds.height)
        //thermoLayer.borderColor = UIColor.green.cgColor
        //thermoLayer.borderWidth = 1
        //print(bounds.height)
        let width = bounds.width - lineWidth
        let path = UIBezierPath(ovalIn: CGRect(x:0+lineWidth/2, y:bounds.maxY-width-lineWidth/2, width:width, height: width))
        //upward line
        path.move(to: CGPoint(x: bounds.midX, y:bounds.maxY-width-lineWidth/2))
        path.addLine(to: CGPoint(x:bounds.midX, y:0+lineWidth/2))
        
        thermoLayer.path = path.cgPath
        thermoLayer.strokeColor = UIColor.darkGray.cgColor
        thermoLayer.fillColor = UIColor.black.cgColor
        thermoLayer.lineWidth = lineWidth
        //thermoLayer.position.x = lineWidth / 2
        thermoLayer.lineCap = CAShapeLayerLineCap.round
        
        maskLayer.path = thermoLayer.path
        maskLayer.lineWidth = thermoLayer.lineWidth - 10
        maskLayer.lineCap = thermoLayer.lineCap
        maskLayer.strokeColor = thermoLayer.strokeColor
        //maskLayer.position.y = 44
        
        maskLayer.fillColor = nil
        //layer.addSublayer(maskLayer)
        buildLevelLayer()
        
        levelLayer.mask = maskLayer
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        addGestureRecognizer(pan)
        
    }
    
    //all of this positioning is really really weird
    private func buildLevelLayer() {
        //print("bulding level layer to: \(level)")
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.width/2, y:bounds.height))
        path.addLine(to: CGPoint(x:bounds.width/2, y:0))
        levelLayer.strokeColor = UIColor.red.cgColor
        levelLayer.path = path.cgPath
        levelLayer.lineWidth = bounds.width
        levelLayer.strokeEnd = level
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer){
        // can probably use this for my chart too!!!
        //it is really weird here, and I don't need this for this, but ...
        let translation = gesture.translation(in: gesture.view)
        let percent = translation.x / bounds.height
        
        level = max(0, min(1, levelLayer.strokeEnd - percent))
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        levelLayer.strokeEnd = level
        CATransaction.commit()
        
        gesture.setTranslation(.zero, in:gesture.view)
    }
}
