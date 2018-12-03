//
//  LineChart.swift
//  LineChart
//
//  Created by Nguyen Vu Nhat Minh on 25/8/17.
//  Copyright © 2017 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit

struct PointEntry2 {
    let value: Int
    let label: String
}

//how can I do this with more than one value and how is it being used? or should I have different entries?
extension PointEntry2: Comparable {
    static func <(lhs: PointEntry2, rhs: PointEntry2) -> Bool {
        return lhs.value < rhs.value
    }
    static func ==(lhs: PointEntry2, rhs: PointEntry2) -> Bool {
        return lhs.value == rhs.value
    }
}

@IBDesignable class MultiLineChart: UIView {
    
    //lets see if this is ok
    
    /// gap between each point
    let lineGap: CGFloat = 60.0
    
    /// preseved space at top of the chart
    let topSpace: CGFloat = 40.0
    
    /// preserved space at bottom of the chart to show labels along the Y axis
    let bottomSpace: CGFloat = 40.0
    
    /// The top most horizontal line in the chart will be 10% higher than the highest value in the chart
    let topHorizontalLine: CGFloat = 110.0 / 100.0
    
    var isCurved: Bool = false

    /// Active or desactive animation on dots
    var animateDots: Bool = false

    /// Active or desactive dots
    var showDots: Bool = false

    /// Dot inner Radius
    var innerRadius: CGFloat = 8

    /// Dot outer Radius
    var outerRadius: CGFloat = 12
    
    var dataEntries: [PointEntry]? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// Contains the main line which represents the data
    private let dataLayer: CALayer = CALayer()
    
    /// To show the gradient below the main line
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    
    /// Contains dataLayer and gradientLayer
    private let mainLayer: CALayer = CALayer()
    
    /// Contains mainLayer and label for each data entry
    private let scrollView: UIScrollView = UIScrollView()
    
    /// Contains horizontal lines
    private let gridLayer: CALayer = CALayer()
    
    /// An array of CGPoint on dataLayer coordinate system that the main line will go through. These points will be calculated from dataEntries array
    
    //changed this to public so I can fuss with it
    public var dataPoints: [CGPoint]?
    
    //for the moving tooltip type thing
    private let popView = UIView() //maybe I can set the alpha of this to 1 when I need it to show. How would I get it to go away?
    private let popLayer = CAShapeLayer()
    private let popTextView = UIView() //for showing the text portions of this ... could maybe do this with the subviews ... I'll need to make the labels and then move it around so maybe I can do that in another function also add this last
    private let toolTipView = ToolTipView()
    private let popLineLayer = CAShapeLayer()//maybe I can just make the layer itself the line
    private let popArrowLayer = CAShapeLayer() //this is going to be the layer for the little boop to connect the line to the text box
    
    private var pointDistances: [CGFloat]?  // will completely re-delete for each time, hopefully this doesn't make it horribly laggy
    
    //I'm going to need to make the line and then show and hide it.

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    private func setupView() {
        mainLayer.addSublayer(dataLayer)
        scrollView.layer.addSublayer(mainLayer)
        
        gradientLayer.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7).cgColor, UIColor.clear.cgColor]
        scrollView.layer.addSublayer(gradientLayer)
        self.layer.addSublayer(gridLayer)
        self.addSubview(scrollView)
        self.backgroundColor = #colorLiteral(red: 0, green: 0.3529411765, blue: 0.6156862745, alpha: 1)
        
        setupToolTip()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        addGestureRecognizer(pan)
    }
    
    //MARK: setup Tool Tip
    private func setupToolTip() {
        popView.frame = CGRect(x: self.bounds.minX, y: self.bounds.minX, width: self.bounds.width, height: self.bounds.height)
        
        popLineLayer.frame = CGRect(x:100, y:0, width:2, height: self.bounds.height-40) // this is what I will modify when I want to move it. maybe I could get this number
        popLineLayer.backgroundColor = UIColor.white.cgColor
        
        //the text box to show info. Need to set frame based on how close it is to the end
        //maybe I should do this in interface builder. I could maybe make it public? NOPE that was super aggravating
        
        
        
        
        popTextView.frame = CGRect (x: popLineLayer.frame.maxX+10, y:10, width:100, height:150)
        popTextView.backgroundColor = UIColor.white
        
        popArrowLayer.frame = CGRect(x: popTextView.frame.minX-10, y:20, width:10, height:10)
        let arrowPath = UIBezierPath(arrowIn: popArrowLayer.bounds)
        //design path in layer
        let arrowLayer = CAShapeLayer()
        arrowLayer.path = arrowPath.cgPath
        arrowLayer.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        arrowLayer.shadowOpacity = 0.7
        arrowLayer.shadowOffset = CGSize(width: 0, height:5.0)
        arrowLayer.shadowRadius = 10.0
        popArrowLayer.addSublayer(arrowLayer)
    
        
        
        toolTipView.frame = popTextView.bounds
        //yasss this works
        popTextView.addSubview(toolTipView)
        
        //popView.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        popView.layer.addSublayer(popLineLayer)
        popView.layer.addSublayer(popLayer)
        popView.layer.addSublayer(popArrowLayer)
        popView.addSubview(popTextView) //hiding so I don't die before class tomorrow
        popView.alpha = 0
        self.addSubview(popView) // can't scroll when popview is there. maybe that will make it so while you are gesturing you won't scroll. Does it work when there's alpha? IT DOES work when alpha is 0.
    }
    
    
    override func layoutSubviews() {
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        if let dataEntries = dataEntries {
            scrollView.contentSize = CGSize(width: CGFloat(dataEntries.count) * lineGap, height: self.frame.size.height)
            mainLayer.frame = CGRect(x: 0, y: 0, width: CGFloat(dataEntries.count) * lineGap, height: self.frame.size.height)
            dataLayer.frame = CGRect(x: 0, y: topSpace, width: mainLayer.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            gradientLayer.frame = dataLayer.frame
            
            //this is what I want. indexes should be the same.
            dataPoints = convertDataEntriesToPoints(entries: dataEntries)
            gridLayer.frame = CGRect(x: 0, y: topSpace, width: self.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            if showDots { drawDots() }
            clean()
            drawHorizontalLines()
            if isCurved {
                drawCurvedChart()
            } else {
                drawChart()
            }
            maskGradientLayer()
            drawLables()
        }
    }
    
    /**
     Convert an array of PointEntry to an array of CGPoint on dataLayer coordinate system
     */
    private func convertDataEntriesToPoints(entries: [PointEntry]) -> [CGPoint] {
        //this will be how i figure out my point.
        //I think this is new so I could reset the array now and then save an array of the points, and the i value. Which I suppose would be the same. oh it already returns an array of CGPoints.
    
        if let max = entries.max()?.value,
            let min = entries.min()?.value {
            
            var result: [CGPoint] = []
            let minMaxRange: CGFloat = CGFloat(max - min) * topHorizontalLine
            
            for i in 0..<entries.count {
                let height = dataLayer.frame.height * (1 - ((CGFloat(entries[i].value) - CGFloat(min)) / minMaxRange))
                let point = CGPoint(x: CGFloat(i)*lineGap + 40, y: height)
                result.append(point)
            }
            return result
        }
        return []
    }
    
    /**
     Draw a zigzag line connecting all points in dataPoints
     */
    private func drawChart() {
        if let dataPoints = dataPoints,
            dataPoints.count > 0,
            let path = createPath() {
            
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.white.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
    }

    /**
     Create a zigzag bezier path that connects all points in dataPoints
     */
    private func createPath() -> UIBezierPath? {
        guard let dataPoints = dataPoints, dataPoints.count > 0 else {
            return nil
        }
        let path = UIBezierPath()
        path.move(to: dataPoints[0])
        
        for i in 1..<dataPoints.count {
            path.addLine(to: dataPoints[i])
        }
        return path
    }
    
    /**
     Draw a curved line connecting all points in dataPoints
     */
    private func drawCurvedChart() {
        guard let dataPoints = dataPoints, dataPoints.count > 0 else {
            return
        }
        if let path = CurveAlgorithm.shared.createCurvedPath(dataPoints) {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.white.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
    }
    
    /**
     Create a gradient layer below the line that connecting all dataPoints
     */
    private func maskGradientLayer() {
        if let dataPoints = dataPoints,
            dataPoints.count > 0 {
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: dataPoints[0].x, y: dataLayer.frame.height))
            path.addLine(to: dataPoints[0])
            if isCurved,
                let curvedPath = CurveAlgorithm.shared.createCurvedPath(dataPoints) {
                path.append(curvedPath)
            } else if let straightPath = createPath() {
                path.append(straightPath)
            }
            path.addLine(to: CGPoint(x: dataPoints[dataPoints.count-1].x, y: dataLayer.frame.height))
            path.addLine(to: CGPoint(x: dataPoints[0].x, y: dataLayer.frame.height))
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            maskLayer.fillColor = UIColor.white.cgColor
            maskLayer.strokeColor = UIColor.clear.cgColor
            maskLayer.lineWidth = 0.0
            
            gradientLayer.mask = maskLayer
        }
    }
    
    /**
     Create titles at the bottom for all entries showed in the chart
     */
    private func drawLables() {
        if let dataEntries = dataEntries,
            dataEntries.count > 0 {
            for i in 0..<dataEntries.count {
                let textLayer = CATextLayer()
                textLayer.frame = CGRect(x: lineGap*CGFloat(i) - lineGap/2 + 40, y: mainLayer.frame.size.height - bottomSpace/2 - 8, width: lineGap, height: 16)
                textLayer.foregroundColor = #colorLiteral(red: 0.5019607843, green: 0.6784313725, blue: 0.8078431373, alpha: 1).cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.alignmentMode = CATextLayerAlignmentMode.center
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 11
                textLayer.string = dataEntries[i].label
                mainLayer.addSublayer(textLayer)
            }
        }
    }
    
    /**
     Create horizontal lines (grid lines) and show the value of each line
     */
    private func drawHorizontalLines() {
        guard let dataEntries = dataEntries else {
            return
        }
        
        var gridValues: [CGFloat]? = nil
        if dataEntries.count < 4 && dataEntries.count > 0 {
            gridValues = [0, 1]
        } else if dataEntries.count >= 4 {
            gridValues = [0, 0.25, 0.5, 0.75, 1]
        }
        if let gridValues = gridValues {
            for value in gridValues {
                let height = value * gridLayer.frame.size.height
                
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0, y: height))
                path.addLine(to: CGPoint(x: gridLayer.frame.size.width, y: height))
                
                let lineLayer = CAShapeLayer()
                lineLayer.path = path.cgPath
                lineLayer.fillColor = UIColor.clear.cgColor
                lineLayer.strokeColor = #colorLiteral(red: 0.2784313725, green: 0.5411764706, blue: 0.7333333333, alpha: 1).cgColor
                lineLayer.lineWidth = 0.5
                if (value > 0.0 && value < 1.0) {
                    lineLayer.lineDashPattern = [4, 4]
                }
                
                gridLayer.addSublayer(lineLayer)
                
                var minMaxGap:CGFloat = 0
                var lineValue:Int = 0
                if let max = dataEntries.max()?.value,
                    let min = dataEntries.min()?.value {
                    minMaxGap = CGFloat(max - min) * topHorizontalLine
                    lineValue = Int((1-value) * minMaxGap) + Int(min)
                }
                
                let textLayer = CATextLayer()
                textLayer.frame = CGRect(x: 4, y: height, width: 50, height: 16)
                textLayer.foregroundColor = #colorLiteral(red: 0.5019607843, green: 0.6784313725, blue: 0.8078431373, alpha: 1).cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 12
                textLayer.string = "\(lineValue)"
                
                gridLayer.addSublayer(textLayer)
            }
        }
    }
    
    private func clean() {
        mainLayer.sublayers?.forEach({
            if $0 is CATextLayer {
                $0.removeFromSuperlayer()
            }
        })
        dataLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        gridLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
    }
    /**
     Create Dots on line points
     */
    private func drawDots() {
        var dotLayers: [DotCALayer] = []
        if let dataPoints = dataPoints {
            for dataPoint in dataPoints {
                let xValue = dataPoint.x - outerRadius/2
                let yValue = (dataPoint.y + lineGap) - (outerRadius * 2)
                let dotLayer = DotCALayer()
                dotLayer.dotInnerColor = UIColor.white
                dotLayer.innerRadius = innerRadius
                dotLayer.backgroundColor = UIColor.white.cgColor
                dotLayer.cornerRadius = outerRadius / 2
                dotLayer.frame = CGRect(x: xValue, y: yValue, width: outerRadius, height: outerRadius)
                dotLayers.append(dotLayer)

                mainLayer.addSublayer(dotLayer)

                if animateDots {
                    let anim = CABasicAnimation(keyPath: "opacity")
                    anim.duration = 1.0
                    anim.fromValue = 0
                    anim.toValue = 1
                    dotLayer.add(anim, forKey: "opacity")
                }
            }
        }
    }
   
    
    //MARK: Gesture Recognizer
    @objc func handlePan(gesture: UIPanGestureRecognizer){
        if(gesture.state == UIGestureRecognizer.State.changed)//this is too slow
        {
            //great this works so I can hide it
            popView.alpha = 1
            //print("gesture started")
        }
        // can probably use this for my chart too!!!
        //it is really weird here, and I don't need this for this, but ...
        //this is what I need, yay!
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let touchPoint = gesture.location(in: self)
        var x = gesture.location(in: self).x
        var bpmstr = ""
        
        var thesedists: [CGFloat] = []
        if let dataPoints = dataPoints, let dataEntries = dataEntries {
            for point in dataPoints {
                thesedists.append(distance(touchPoint, point))
            }
            
            let smallest = thesedists.min()
            if let smallest = smallest {
                if let smallesti = thesedists.firstIndex(of: smallest) {
                    let data = dataEntries[smallesti]
                    let point = dataPoints[smallesti]
                    
                    //get the location. make sure it works after scrolling
                    x = point.x
                    
                    //get the values ... may need to do it for 3 different arrays. will see. Or I could put it there and do the 3 different arrays just for the points. or something.
                    bpmstr = String(data.value)
                }
            }
        }
        
        //move the components around
        popLineLayer.frame.origin.x = x
        // need to check how to move that around
    if(((popLineLayer.frame.maxX+10)+popTextView.frame.width)>self.frame.maxX){
            //going outside frame, flip to other side
            popTextView.frame.origin.x  = popLineLayer.frame.minX-10-popTextView.frame.width
            popArrowLayer.transform = CATransform3DMakeScale(-1, 1, 1) // flip it ... could also rotate?
            popArrowLayer.frame.origin.x = popTextView.frame.maxX
        }else{
            popTextView.frame.origin.x  = popLineLayer.frame.maxX+10
            // do I need to flip it back? yes and this works awesome. 
            popArrowLayer.transform = CATransform3DMakeScale(1, 1, 1)
            popArrowLayer.frame.origin.x = popLineLayer.frame.maxX
        }
        //obviously replace with the info from the chart ... and ADD TIME
        toolTipView.updateValues(bpm: bpmstr, gsr: "gsrstr", temp: "tempstr", mood: "moodstr")
        
        CATransaction.commit()
        
        //print("Transaltion  \(translation)")
        print("x:  \(x)")
        
        // now I think I need to add a layer and put some stuff in it. and I will need to find where I am on that layer.
        //maybe I want to make the layers outside of their things so I can access them better.
        //and maybe I should do this with a view
        
        //and maybe I should make them before hand and then move them.
        
        
        
        /*
        let percent = translation.x / bounds.height
        level = max(0, min(1, levelLayer.strokeEnd - percent))
        
        //this was to get rid of animation
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        levelLayer.strokeEnd = level
        CATransaction.commit()
        */
        
        gesture.setTranslation(.zero, in:gesture.view)
        
        if(gesture.state == UIGestureRecognizer.State.ended)
        {
            popView.alpha = 0
            //great this works so I can hide it
            print("gesture over")
        }
    }
}

func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    let xDist = a.x - b.x
    let yDist = a.y - b.y
    return CGFloat(sqrt(xDist * xDist + yDist * yDist))
}
