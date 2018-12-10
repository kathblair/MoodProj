//
//  drawing.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-20.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
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
        print(screenWidth)
        //could I pass this? or set it if there are bounds?
        var thermow: CGFloat
        if (bounds.width>0){
            thermow = bounds.width
        }else{
            thermow = 100
        }
        
        var thermoh: CGFloat
        if (bounds.height>0){
            thermoh = bounds.height
        }else{
            thermoh = 200
        }
        
        var thermox: CGFloat
        if (bounds.minX>0){
            thermox = bounds.minX
        }else{
            thermox = CGFloat(Int(screenWidth)-Int(thermow))
        }
        
        
        var thermoy: CGFloat
        if (bounds.minY>0){
            thermoy = bounds.minY
        }else{
            thermoy = CGFloat(Int(screenHeight)-Int(thermoh)*2)
        }
        
        self.frame = CGRect (x:Int(thermox)-Int(thermow/4), y:Int(thermoy), width:Int(thermow), height:Int(thermoh))
        thermoLayer.frame = CGRect(x: bounds.minX, y:bounds.minY+44, width:bounds.width, height: bounds.height)
        //thermoLayer.borderColor = UIColor.green.cgColor
        //thermoLayer.borderWidth = 5
        let width = bounds.width - lineWidth
        let height = bounds.height - lineWidth / 2
        let path = UIBezierPath(ovalIn: CGRect(x:0, y:height-width, width:width, height: width))
        
        //upward line
        path.move(to: CGPoint(x: width/2, y:height-width))
        path.addLine(to: CGPoint(x:width/2, y:-height+width))
        
        thermoLayer.path = path.cgPath
        thermoLayer.strokeColor = UIColor.darkGray.cgColor
        thermoLayer.lineWidth = lineWidth
        //thermoLayer.position.x = lineWidth / 2
        thermoLayer.lineCap = CAShapeLayerLineCap.round
        
        maskLayer.path = thermoLayer.path
        maskLayer.lineWidth = thermoLayer.lineWidth - 6
        maskLayer.lineCap = thermoLayer.lineCap
        //maskLayer.position = thermoLayer.position
        maskLayer.strokeColor = thermoLayer.strokeColor
        //maskLayer.strokeColor = UIColor.blue.cgColor
        maskLayer.position.y = 44
        
        maskLayer.fillColor = nil
        //layer.addSublayer(maskLayer) // haha I will need to figure that out ....
        buildLevelLayer()
        
        levelLayer.mask = maskLayer
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        addGestureRecognizer(pan)
    }
    
    //all of this positioning is really really weird
    private func buildLevelLayer() {
        print("bulding level layer to: \(level)")
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX+35, y:bounds.height+40))
        path.addLine(to: CGPoint(x:bounds.minX+35, y:bounds.height-bounds.height-10))
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
