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

struct PointEntryT {
    let value: Int
    let label: String
    let time: TimeInterval
}

struct PointEntry3 {
    let value: Float
    let label: String
    let time: TimeInterval
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

extension PointEntryT: Comparable {
    static func <(lhs: PointEntryT, rhs: PointEntryT) -> Bool {
        return lhs.value < rhs.value
    }
    static func ==(lhs: PointEntryT, rhs: PointEntryT) -> Bool {
        return lhs.value == rhs.value
    }
}

extension PointEntry3: Comparable {
    static func <(lhs: PointEntry3, rhs: PointEntry3) -> Bool {
        return lhs.value < rhs.value
    }
    static func ==(lhs: PointEntry3, rhs: PointEntry3) -> Bool {
        return lhs.value == rhs.value
    }
}
//ugh maybe I should do it in 3 arrays ...
//need to do this a different way and just make a function to compare
//or maybe I can just directly compare the numbers because they are already comparable. Duh. Just instead of comparing the points I'lll compare the relevant values

class MultiLineChart: UIView {
    
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
    
    //this is kinda the thing I need to do to see when the stuff changes.
    //maybe I can make this an array of 3 things.
    //var dataEntries: [PointEntry3]? {
    var dataEntries: [String:[PointEntry3]]? {
        //maybe I can turn this off
        didSet {
            self.setNeedsLayout()
        }
    }
    
    //check in the food thing for how to properly initialize
    //need an empty datastack I guess?
    var dataStack: DataStack?
    
    /// Contains the main line which represents the data
    private let dataLayer: CALayer = CALayer()
    
    /// To show the gradient below the main line
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    //should make one for each one
    
    /// Contains dataLayer and gradientLayer
    private let mainLayer: CALayer = CALayer()
    
    /// Contains mainLayer and label for each data entry
    private let scrollView: UIScrollView = UIScrollView()
    
    /// Contains horizontal lines
    private let gridLayer: CALayer = CALayer()
    
    /// An array of CGPoint on dataLayer coordinate system that the main line will go through. These points will be calculated from dataEntries array
    
    //changed this to public so I can fuss with it
    //for the 3 series
    //not sure I'll do it this way actually. each would have a different y but the same x
    private var bpmDataPoints: [CGPoint]? = []
    private var gsrDataPoints: [CGPoint]? = []
    private var tempDataPoints: [CGPoint]? = []
    
    //for the moving tooltip type thing
    private let popView = UIView() //maybe I can set the alpha of this to 1 when I need it to show. How would I get it to go away?
    private let popLayer = CAShapeLayer()
    private let popTextView = UIView() //for showing the text portions of this ... could maybe do this with the subviews ... I'll need to make the labels and then move it around so maybe I can do that in another function also add this last
    private let toolTipView = ToolTipView()
    private let popLineLayer = CAShapeLayer()//maybe I can just make the layer itself the line
    private let popArrowLayer = CAShapeLayer() //this is going to be the layer for the little boop to connect the line to the text box
    
    private var pointDistances: [CGFloat]?  // will completely re-delete for each time, hopefully this doesn't make it horribly laggy
        //and also for this I really think I just need X distances
    
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
    
    //MARK: setupView
    private func setupView() {
        mainLayer.addSublayer(dataLayer)
        scrollView.layer.addSublayer(mainLayer)
        
        //sets up the gradient layer, think I would want to do this 3 times.
        //maybe I should redo the functions and pass them the data points.
        //or make 3 lines in each one.
        //and I could make a comparable funciton that sends the point?
        gradientLayer.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7).cgColor, UIColor.clear.cgColor]
        scrollView.layer.addSublayer(gradientLayer)
        self.layer.addSublayer(gridLayer)
        self.addSubview(scrollView) //this isn't working right now
        //self.backgroundColor = #colorLiteral(red: 0, green: 0.3529411765, blue: 0.6156862745, alpha: 1)
        
        setupToolTip()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        addGestureRecognizer(pan)
    }
    
    //MARK: setup Tool Tip
    private func setupToolTip() {
        popView.frame = CGRect(x: self.bounds.minX, y: self.bounds.minX, width: self.bounds.width, height: self.bounds.height)
        
        popLineLayer.frame = CGRect(x:100, y:0, width:2, height: self.bounds.height-40) // this is what I will modify when I want to move it. maybe I could get this number
        popLineLayer.backgroundColor = UIColor.black.cgColor
        
        //the text box to show info. Need to set frame based on how close it is to the end
        //maybe I should do this in interface builder. I could maybe make it public? NOPE that was super aggravating
        
        popTextView.frame = CGRect (x: popLineLayer.frame.maxX+10, y:10, width:100, height:150)
        popTextView.backgroundColor = UIColor.white
        popTextView.layer.shadowOpacity = 0.7
        popTextView.layer.shadowOffset = CGSize(width: 0, height:5.0)
        popTextView.layer.shadowRadius = 10.0
        
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
        //this is where the actual work is done so HERE is where I need to like  .... do the work
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        if let dataEntries = dataEntries, let bpmseries = dataEntries["bpm"] {
            scrollView.contentSize = CGSize(width: CGFloat(bpmseries.count) * lineGap, height: self.frame.size.height)
            mainLayer.frame = CGRect(x: 0, y: 0, width: CGFloat(bpmseries.count) * lineGap, height: self.frame.size.height)
            
            //MARK: datalayer
            //maybe I need to make a few of these
            let dataframe = CGRect(x: 0, y: topSpace, width: mainLayer.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            //can I make all of them the same
            dataLayer.frame = dataframe
            gradientLayer.frame = dataLayer.frame
            
            //MARK: dataSeries to change
            //this is what I want. indexes should be the same.
            //ugggh maybe I should break it into 3 and then I can easily reuse all that code. But then I have a stupid number of variables.
            
            //and I'll need to pass things to the functions. Or just do all 3.
            if let bpmp = dataEntries["bpm"], let gsrp = dataEntries["gsr"], let tempp = dataEntries["temp"]{
                bpmDataPoints = convertDataEntriesToPoints(entries: bpmp)
                gsrDataPoints = convertDataEntriesToPoints(entries: gsrp)
                tempDataPoints = convertDataEntriesToPoints(entries: tempp)
                gridLayer.frame = CGRect(x: 0, y: topSpace, width: self.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
                
                if let bpmDataPoints=bpmDataPoints, let gsrDataPoints=gsrDataPoints, let tempDataPoints=tempDataPoints {
                    if showDots {
                        drawDots(points: bpmDataPoints, dotcolor: UIColor.red)
                        drawDots(points: gsrDataPoints, dotcolor: UIColor.blue)
                        drawDots(points: tempDataPoints, dotcolor: UIColor.yellow)
                        }
                    clean()
                    drawHorizontalLines() // figure this out with all 3, find a way to indicate scale ... scroll should be INSIDE this
                    if isCurved {
                        drawCurvedChart(points: bpmDataPoints, strokecolor: UIColor.red.cgColor)
                        drawCurvedChart(points: gsrDataPoints, strokecolor: UIColor.blue.cgColor)
                        drawCurvedChart(points: tempDataPoints, strokecolor: UIColor.yellow.cgColor)
                    } else {
                        drawChart(points: bpmDataPoints, strokecolor: UIColor.red.cgColor)
                        drawChart(points: gsrDataPoints, strokecolor: UIColor.blue.cgColor)
                        drawChart(points: tempDataPoints, strokecolor: UIColor.yellow.cgColor)
                    }
                    //I think this is all replacing the same layer.
                    maskGradientLayer(points: bpmDataPoints, fillcolor: UIColor.red.cgColor)
                    maskGradientLayer(points: gsrDataPoints, fillcolor: UIColor.blue.cgColor)
                    maskGradientLayer(points: tempDataPoints, fillcolor: UIColor.yellow.cgColor)
                    drawLables(foregroundcolor: UIColor.black.cgColor) // only do that for one
                }
                
            }
        }
    }
    
    /**
     Convert an array of PointEntry to an array of CGPoint on dataLayer coordinate system
     */
    private func convertDataEntriesToPoints(entries: [PointEntry3]) -> [CGPoint] {
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
    private func drawChart(points: [CGPoint], strokecolor:CGColor) {
        if points.count > 0,
            let path = createPath(points: points) {
            
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = strokecolor // should set these earlier and maybe like for each one do a diff color
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
            }
    }

    /**
     Create a zigzag bezier path that connects all points in dataPoints
     */
    private func createPath(points: [CGPoint]) -> UIBezierPath? {
        guard points.count > 0 else {
            return nil
        }
        let path = UIBezierPath()
        path.move(to: points[0])
        
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        return path
    }
    
    /**
     Draw a curved line connecting all points in dataPoints
     */
    private func drawCurvedChart(points: [CGPoint], strokecolor:CGColor) {
        guard points.count > 0 else {
            return
        }
        if let path = CurveAlgorithm.shared.createCurvedPath(points) {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = strokecolor
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
    }
    
    /**
     Create a gradient layer below the line that connecting all dataPoints
     */
    //THIS ONE uses the real fill colour and all the other ones use the clear one
    private func maskGradientLayer(points: [CGPoint], fillcolor:CGColor) {
        if points.count > 0 {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: points[0].x, y: dataLayer.frame.height))
            path.addLine(to: points[0])
            if isCurved,
                let curvedPath = CurveAlgorithm.shared.createCurvedPath(points) {
                path.append(curvedPath)
            } else if let straightPath = createPath(points: points) {
                path.append(straightPath)
            }
            path.addLine(to: CGPoint(x: points[points.count-1].x, y: dataLayer.frame.height))
            path.addLine(to: CGPoint(x: points[0].x, y: dataLayer.frame.height))
            
            let thisgradientLayer: CAGradientLayer = CAGradientLayer()
            //did this work?
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            maskLayer.fillColor = fillcolor
            maskLayer.strokeColor = UIColor.clear.cgColor
            maskLayer.lineWidth = 0.0
            
            //need 3 of these.
            thisgradientLayer.mask = maskLayer
            //gradientLayer.addSublayer(thisgradientLayer)
            
            gradientLayer.mask = maskLayer
        }
    }
    
    /**
     Create titles at the bottom for all entries showed in the chart
     */
    private func drawLables(foregroundcolor: CGColor) {
        if let dataEntries = dataEntries, let entries = dataEntries["bpm"],
            entries.count > 0 {
            for i in 0..<entries.count {
                let textLayer = CATextLayer()
                textLayer.frame = CGRect(x: lineGap*CGFloat(i) - lineGap/2 + 40, y: mainLayer.frame.size.height - bottomSpace/2 - 8, width: lineGap, height: 16)
                textLayer.foregroundColor = foregroundcolor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.alignmentMode = CATextLayerAlignmentMode.center
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 11
                textLayer.string = entries[i].label
                mainLayer.addSublayer(textLayer)
            }
        }
    }
    
    //MARK: Gridlines
    //I only need THIS once, but I kind of need to do it 3 times
    /**
     Create horizontal lines (grid lines) and show the value of each line
     */
    private func drawHorizontalLines() {
        guard let dataEntries = dataEntries, let bpmentries = dataEntries["bpm"], let gsrentries = dataEntries["gsr"], let tempentries = dataEntries["temp"]  else {
            return
        }
        
        print(bpmentries.count)
        print(gsrentries.count)
        print(tempentries.count)
        
        //gridvalues - should all be the same so just use bpm because the count will be the same
        var gridValues: [CGFloat]? = nil
        if bpmentries.count < 4 && bpmentries.count > 0 {
            gridValues = [0, 1]
        } else if bpmentries.count >= 4 {
            gridValues = [0, 0.25, 0.5, 0.75, 1]
        }
        
        //this is drawing the lines
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
                
                //bpm text calc
                var bminMaxGap:CGFloat = 0
                var blineValue:Int = 0
                if let bmax = bpmentries.max()?.value,
                    let bmin = bpmentries.min()?.value {
                    bminMaxGap = CGFloat(bmax - bmin) * topHorizontalLine
                    blineValue = Int((1-value) * bminMaxGap) + Int(bmin)
                }
                
                //temp text calc
                var tminMaxGap:CGFloat = 0
                var tlineValue:Int = 0
                if let tmax = tempentries.max()?.value,
                    let tmin = tempentries.min()?.value {
                    tminMaxGap = CGFloat(tmax - tmin) * topHorizontalLine
                    tlineValue = Int((1-value) * tminMaxGap) + Int(tmin)
                }
                
                //leaving out a scale for GSR
                
                //scale for bpm
                let bpmtextLayer = CATextLayer()
                bpmtextLayer.frame = CGRect(x: 4, y: height, width: 50, height: 16)
                bpmtextLayer.foregroundColor = #colorLiteral(red: 0.5019607843, green: 0.6784313725, blue: 0.8078431373, alpha: 1).cgColor
                bpmtextLayer.backgroundColor = UIColor.clear.cgColor
                bpmtextLayer.contentsScale = UIScreen.main.scale
                bpmtextLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                bpmtextLayer.fontSize = 12
                bpmtextLayer.string = "\(blineValue)"
                gridLayer.addSublayer(bpmtextLayer)
                
                //scale for temp
                let temptextLayer = CATextLayer()
                //need to find a good place to actually put it. I would like these to stay still while the inside scrolls .... and there is a CA Scroll Layer and maybe that's what I'm using so hopefully that's OK, I can just change the order of the scroll layer. Or insert these things higher up in the tree
                //trying to put it on the rightmost side.
                temptextLayer.frame = CGRect(x: gridLayer.bounds.maxX-4, y: height, width: 50, height: 16)
                temptextLayer.foregroundColor = #colorLiteral(red: 0.5019607843, green: 0.6784313725, blue: 0.8078431373, alpha: 1).cgColor
                temptextLayer.backgroundColor = UIColor.clear.cgColor
                temptextLayer.contentsScale = UIScreen.main.scale
                temptextLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                temptextLayer.fontSize = 12
                temptextLayer.string = "\(tlineValue)"
                gridLayer.addSublayer(temptextLayer)
                
                //decided scale for gsr wasn't a big deal
                
                
            }
        }
    }
    
    //MARK: Clean
    /**
     Cleaning - not sure what this does
     */
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
    private func drawDots(points: [CGPoint], dotcolor:UIColor) {
        var dotLayers: [DotCALayer] = []
        //if let dataPoints = dataPoints {
            for point in points {
                //what is outerradius?
                let xValue = point.x - outerRadius/2
                let yValue = (point.y + lineGap) - (outerRadius * 2)
                let dotLayer = DotCALayer()
                dotLayer.dotInnerColor = dotcolor
                dotLayer.innerRadius = innerRadius
                dotLayer.backgroundColor = dotcolor.cgColor
                dotLayer.cornerRadius = outerRadius / 2
                dotLayer.frame = CGRect(x: xValue, y: yValue, width: outerRadius, height: outerRadius)
                dotLayers.append(dotLayer)

                mainLayer.addSublayer(dotLayer) //should this be dotLAYERS? and lower down?

                if animateDots {
                    let anim = CABasicAnimation(keyPath: "opacity")
                    anim.duration = 1.0
                    anim.fromValue = 0
                    anim.toValue = 1
                    dotLayer.add(anim, forKey: "opacity")
                }
            }
        //}
    }
   
    
    //MARK: Gesture Recognizer
    @objc func handlePan(gesture: UIPanGestureRecognizer){
        if(gesture.state == UIGestureRecognizer.State.changed) {//this is too slow
            //great this works so I can hide it
            popView.alpha = 1
            //print("gesture started")
        }
        // can probably use this for my chart too!!!
        //it is really weird here, and I don't need this for this, but ...
        //this is what I need, yay!
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        //let touchPoint = gesture.location(in: self)
        var x = gesture.location(in: self).x
        var bpmstr = ""
        var gsrstr = ""
        var tempstr = ""
        var moodstr = ""
        
        var thesedists: [CGFloat] = []
        if let dataPoints = bpmDataPoints, let dataEntries = dataEntries {
            for point in dataPoints {  //think I can just use the difference in x value actually
                thesedists.append(abs(x-point.x))
            }
            
            let smallest = thesedists.min()
            if let smallest = smallest, let smallesti = thesedists.firstIndex(of: smallest),  let bpmdata = dataEntries["bpm"] {
                    let point = dataPoints[smallesti]
                    //get the location. make sure it works after scrolling
                    x = point.x
                    
                    if let dataStack=dataStack, let data = dataStack.data {
                        print(bpmdata.count)
                        print(data.count)
                        //maybe I can just pass the whole datastack to the modal controllers and modify there?
                        print(bpmdata[smallesti].time)
                        print(data[smallesti].time)
                        
                        bpmstr = String(data[smallesti].bpm)
                        gsrstr = String(Int(data[smallesti].gsr))
                        tempstr = String(Int(data[smallesti].temp))
                        
                        //need to make sure I have access to the baseline as well ... where did I calculate  it? In the prediction right?
                        //also gotta set it when I set the datastack. Could I add it TO the datastack? It is already
                        let predmood = data[smallesti].returnMoodPrediction(baseline: dataStack.baseline)
                        moodstr = "\(predmood)"
                        
                        //if we haven't saved a prediction in a while, save this one
                        let date = Date()
                        //also are we saving data only once per second? I think yes, I think it's like a 5 second interval
                        let prediction = Prediction(timecreated: date.timeIntervalSince1970, mood: predmood, confirmed: false, note: "", dataPoint: data[smallesti])
                        
                        if let preds = dataStack.predictions, let prediction = prediction {
                            if preds.count > 0 {
                                //filter them
                                let arr = preds.filter {
                                    $0.dataPoint.time == prediction.dataPoint.time
                                    }
                                if arr.count>0 {
                                    // mathcing time so we don't need it.
                                }else{
                                    //check last time, just use the most recent-ish one I guess, I should probably find a better way to check that
                                    let timediff = prediction.dataPoint.time - preds[0].dataPoint.time
                                    let predinterval = 15*60 // 60 mins in seconds
                                    if Int(timediff) > predinterval {
                                        //time to save it to the stack
                                        dataStack.predictions?.append(prediction)
                                    }
                                }
                            }else{
                                //add this prediction becasue we have none
                                dataStack.predictions?.append(prediction)
                            }
                        } // end let preds ...
                    } // end let data ...
                }//end let smallesti ...
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
            popArrowLayer.transform = CATransform3DMakeScale(1, 1, 1)
            popArrowLayer.frame.origin.x = popLineLayer.frame.maxX
        }
        //obviously replace with the info from the chart ... and ADD TIME
        toolTipView.updateValues(bpm: bpmstr, gsr: gsrstr, temp: tempstr, mood: moodstr)
        
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
