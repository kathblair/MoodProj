//
//  IntroViewController.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-20.
//
/*
 Helpful sources for this code:
 “Core Graphics - How to Draw Heart Shape in UIView (IOS)? -.” 2015. Stack Overflow. 2015. https://stackoverflow.com/questions/29227858/how-to-draw-heart-shape-in-uiview-ios.
 Begbie, Caroline. 2018. “Drawing in IOS · Custom Control.” Raywenderlich.Com. 2018. https://www.raywenderlich.com/4659-drawing-in-ios/lessons/5.
 */

import UIKit
import Firebase
import os.log

class IntroViewController: UIViewController, DataProtocolClient {
    

    
    @IBOutlet weak var overviewTab: UITabBarItem!
    @IBOutlet weak var viewForLayer: UIView!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var confirmationView: UIView!
    
    
    //wonder if this is why I was having trouble???
    var layer: CALayer {
        return viewForLayer.layer
    }
    
    //putting the things I need to edit so I can access from the update function
    //in this context, this is the main label so I'm going to use it as the base, actually
    let bpmvalue = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    let bpmlabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    //gradient layer. colour will need to be based on data
    let gradLayer = CAGradientLayer()
    //in this context, this is the main label so I'm going to use it as the base, actually
    let gsrvalue = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    //in this context, this is the main label so I'm going to use it as the base, actually
    let gsrlabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    let gsrsublabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    let tempvalue = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    let thermoview = ThermometerView(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    let heartLayer = CALayer()
    let heartAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.bounds))
    let heartPathAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
    let shapeLayer = CAShapeLayer()
    let dropLayer = CALayer()
    let templabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    
    var predictedMood:Prediction.moods? = nil
    var thisPrediction:Prediction? = nil
    
    var dataStack: DataStack? {
        didSet {
            // this doesn't make the stuff refresh but I should re-factor to match the way the timeline view is done
            viewForLayer.setNeedsLayout()
            //adds text each time, need to stop that. Sigh. But if I move them to the top that should work ... or just do an update layer ...
            updateLayer()
        }
    }
    
    func setData(data: DataStack) {
        self.dataStack = data
    }
    
    
    //may need to watch for that changing
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //super.viewDidAppear()
        updateLayer() // would this get the animation to restart?
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Save the prediction
        //decide if I want to save this prediction, and if so, save them.
        if let pred = thisPrediction, let dataStack = dataStack, var preds = dataStack.predictions {
            let lastpredtime = preds[0].time
            let saveinterval = 15*60
            //print(preds[preds.count-1].time)
            let ps = preds.filter{$0.time == pred.time}
            if(ps.count>0){
                //this prediction already exists, no need to save
            }else{
                if(pred.time-lastpredtime>Double(saveinterval)){
                    //haven't saved a prediction in a 15 mins so save this one even if it hasn't been confirmed
                    preds.append(pred)
                    dataStack.savePredictions(predictions: preds)
                }
            }
        }
    }
    
    // to make everything rotate nicely.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLocations()
    }
    
    //update where everything is when the frame has changed
    func updateLocations(){
        //update the background gradient
        gradLayer.frame = self.view.bounds
        
        var dropx = heartLayer.frame.minX
        var dropy = heartLayer.frame.maxY-dropLayer.frame.height/2
        var thermox = heartLayer.frame.maxX-thermoview.frame.width/4
        var thermoy = heartLayer.frame.maxY-thermoview.frame.height/2
        
        
        //update position of the confirmation view
        let ar = screenHeight/screenWidth
        if (ar>1) {
            //base the position off the default position of the confirmation view
            heartLayer.position = CGPoint(x: confirmationView.center.x, y:(screenHeight-(screenHeight-(confirmationView.center.y-confirmationView.bounds.height/2)))/2)
            
            //change the drop and thermometer y values to space them out more nicely. basing them both on thermometer to make it a little more proportional looking.
            dropy = dropy+thermoview.bounds.height/2
            thermoy = thermoy+thermoview.bounds.height/2.5
            
        }else if(ar<1){
            //first move the confirmation view to a reasonable place ... I think it would be easier to use with my LEFT than RIGHT thumb so put it on the left.
            let centeryval = screenHeight/2-confirmationView.bounds.height/4
            confirmationView.center = CGPoint(x:screenWidth/4, y:centeryval)
            
            //now move the heart to the center of the remaining space
            let maxx = confirmationView.center.x+confirmationView.bounds.width/2
            let heartx = (screenWidth-maxx)/2+maxx
            heartLayer.position = CGPoint(x:heartx, y:centeryval)
            
            //change the x-values for the drop and thermometer to make them look nice, basing both on the thermo so they look somewhat proportional
            dropx = dropx-thermoview.bounds.width/2
            thermox = thermox+thermoview.bounds.width/2
        }else{
            //ar is equal to 1, it's a square device
            heartLayer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
        }
        //update positions of other icons relative to the heart
        dropLayer.position = CGPoint(x:dropx, y:dropy)
        thermoview.center = CGPoint(x: thermox, y:thermoy)
        
        //make sure they aren't outside the bounds and pop them in if they are
        if(dropLayer.bounds.minX<20){
            dropLayer.position.x = dropLayer.position.x+20;
        }
        let cval = screenWidth-(thermoview.center.x+(thermoview.bounds.width/2))
        if(abs(cval)<20){
            thermoview.center.x = thermoview.center.x-20
        }
        
        //update the locations of the labels
        bpmvalue.center = CGPoint(x: heartLayer.position.x+5, y: heartLayer.position.y+heartLayer.frame.height/16)
        bpmlabel.center = CGPoint(x: bpmvalue.center.x, y: bpmvalue.center.y-bpmvalue.frame.height/2)
        
        gsrvalue.center = CGPoint(x: dropLayer.position.x+gsrvalue.frame.width/5, y: dropLayer.position.y-gsrvalue.frame.height/2)
        gsrlabel.center = CGPoint(x: gsrvalue.center.x, y: gsrvalue.center.y-gsrvalue.frame.height/2)
        gsrsublabel.center = CGPoint(x: gsrvalue.center.x, y: gsrvalue.center.y+gsrvalue.frame.height/2)

        tempvalue.center = CGPoint(x: thermoview.center.x, y:thermoview.center.y)
        templabel.center = CGPoint(x: tempvalue.center.x, y: tempvalue.center.y-tempvalue.frame.height/2)
    }
    

    func setUpLayer() { // draws the components
    
        gradLayer.frame = self.view.bounds
        gradLayer.colors = [colors[3].cgColor, colors[4].cgColor]
        layer.addSublayer(gradLayer)
        
        // this will need to be changed based on data. I wonder when I should do the data getting. and see if I can make it public, when i should recheck it
        
        //draw the heart ... could make it a function?
        //also maybe I want the width and height to be constant
        //let smallerdim = min(self.view.bounds.width, self.view.bounds.height)
        
        let heartw = Double(250)
        let hearth = heartw
        //should I make it smaller and bigger as you go?
        heartLayer.frame = CGRect(x: 0, y: 0, width: heartw, height: hearth) // top left
        
        let bezierPath = UIBezierPath(heartIn: heartLayer.bounds)

        //design path in layer
        //shapeLayer.path = path.cgPath
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.strokeColor = colors[7].cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.fillColor = colors[5].cgColor
        shapeLayer.shadowOpacity = 0.7
        shapeLayer.shadowOffset = CGSize(width: 0, height:5.0)
        shapeLayer.shadowRadius = 10.0
        heartLayer.addSublayer(shapeLayer)
        
        //need to do the beat animation
        let oldbValue = heartLayer.bounds
        //ok so I want the animation to be, it gets a little bigger, but stays in the same place
        let newbValue = CGRect(x: 0, y: 0, width: heartLayer.bounds.width+50, height: heartLayer.bounds.height+50)
        
        heartAnimation.fromValue = oldbValue
        heartAnimation.toValue = newbValue
        heartAnimation.duration = 10.0
        heartAnimation.repeatCount = .greatestFiniteMagnitude
        heartAnimation.autoreverses = true
        heartLayer.bounds = newbValue
        
        let newPath = UIBezierPath(heartIn: heartLayer.bounds)
        heartPathAnimation.fromValue = shapeLayer.path
        heartPathAnimation.toValue = newPath.cgPath
        heartPathAnimation.duration = 10.0
        heartPathAnimation.repeatCount = .greatestFiniteMagnitude
        heartPathAnimation.autoreverses = true
        shapeLayer.path = newPath.cgPath
        //heartLayer.add(heartAnimation, forKey: #keyPath(CALayer.bounds)) not having this here makes it not do awkward changing
        
        layer.addSublayer(heartLayer)
        

        
        
        // you will probably want to set the font (remember to use Dynamic Type!)
        bpmvalue.font = UIFont.preferredFont(forTextStyle: .title1)
        bpmvalue.font = bpmvalue.font.withSize(70)
        bpmvalue.textColor = .white
        bpmvalue.textAlignment = .center
        // need to get programatically, also after we've actually gotten the data
        // plus i need to animate the heart
        bpmvalue.text = " "
        bpmvalue.sizeToFit()
        self.view.addSubview(bpmvalue)
        
        //add labels
        // you will probably want to set the font (remember to use Dynamic Type!)
        bpmlabel.font = UIFont.preferredFont(forTextStyle: .title1)
        bpmlabel.textColor = .white
        bpmlabel.textAlignment = .center
        bpmlabel.text = "BPM:"
        self.view.addSubview(bpmlabel)
        
        //draw the droplet
        let dropw = heartw*0.275
        let droph = dropw*1.5
        dropLayer.frame = CGRect(x: 0, y: 0, width: dropw, height: droph)
        let dropbezierPath = UIBezierPath(dropIn: dropLayer.bounds)
        
        //design path in layer
        let dropshapeLayer = CAShapeLayer()
        //shapeLayer.path = path.cgPath
        dropshapeLayer.path = dropbezierPath.cgPath
        //dropshapeLayer.strokeColor = colors[7].cgColor
        dropshapeLayer.lineWidth = 2.0
        dropshapeLayer.fillColor = colors[1].cgColor
        dropshapeLayer.shadowOpacity = 0.7
        dropshapeLayer.shadowOffset = CGSize(width: 0, height:5.0)
        dropshapeLayer.shadowRadius = 10.0
        dropLayer.addSublayer(dropshapeLayer)
        
        layer.addSublayer(dropLayer)
        

        // you will probably want to set the font (remember to use Dynamic Type!)
        gsrvalue.font = UIFont.preferredFont(forTextStyle: .title1)
        gsrvalue.font = bpmvalue.font.withSize(70)
        gsrvalue.textColor = .white
        gsrvalue.textAlignment = .center
        // need to get programatically, also after we've actually gotten the data
        // plus i need to animate the heart
        gsrvalue.text = ""
        gsrvalue.sizeToFit()
        self.view.addSubview(gsrvalue)
        
        
        
        //add labels
        // you will probably want to set the font (remember to use Dynamic Type!)
        gsrlabel.font = UIFont.preferredFont(forTextStyle: .title1)
        gsrlabel.textColor = .white
        gsrlabel.textAlignment = .center
        gsrlabel.text = "GSR:"
        gsrlabel.sizeToFit()
        self.view.addSubview(gsrlabel)
        
        gsrsublabel.font = UIFont.preferredFont(forTextStyle: .title1)
        gsrsublabel.textColor = .white
        gsrsublabel.textAlignment = .center
        gsrsublabel.text = ""
        gsrsublabel.sizeToFit()
        self.view.addSubview(gsrsublabel)
        
        // now I need to add the labels for that, but let's see about the thermometer
        // doing that in the designer isn't working. But I can see it.
        var tframe = thermoview.frame
        tframe.size.width = CGFloat(dropw*1.5)
        tframe.size.height = tframe.size.width*2
        thermoview.frame = tframe
        thermoview.thermoLayer.frame = tframe
        thermoview.drawContents()
        self.view.addSubview(thermoview)
        
        // you will probably want to set the font (remember to use Dynamic Type!)
        tempvalue.font = UIFont.preferredFont(forTextStyle: .title1)
        tempvalue.font = bpmvalue.font.withSize(70)
        tempvalue.textColor = .white
        tempvalue.textAlignment = .center
        // need to get programatically, also after we've actually gotten the data
        // plus i need to animate the heart
        tempvalue.text = " "
        tempvalue.sizeToFit()
        self.view.addSubview(tempvalue)
        
        //add labels

        // you will probably want to set the font (remember to use Dynamic Type!)
        templabel.font = UIFont.preferredFont(forTextStyle: .title1)
        templabel.textColor = .white
        templabel.textAlignment = .center
        templabel.text = "Temp:"
        templabel.sizeToFit()
        self.view.addSubview(templabel)
        
        updateLocations()
    }

    //updates the layer data.
    func updateLayer(){
        //Making the prediction
        //Maybe move this above and check it in updateprediction and see if we need to do anything with it
        if let dataStack = dataStack, let data = dataStack.data, let preds = dataStack.predictions {
            
            predictedMood = data[0].returnMoodPrediction(baseline: dataStack.baseline)
            let predictiontime = data[0].time
            let matches = preds.filter{
                $0.time == predictiontime
            }
            
            if(matches.count>0){
                thisPrediction = matches[0];
            }else{
                if let predictedMood = predictedMood {
                    
                    thisPrediction = Prediction(timecreated: NSDate().timeIntervalSince1970, mood: predictedMood, confirmed: false, note: "", time: data[0].time, millis: data[0].millis, gsr: data[0].gsr, gsreval:data[0].gsreval, bpm: data[0].bpm, temp: data[0].temp)
                    //false because it's not been confirmed in the popup yet
                    moodLabel.text = "\(predictedMood)"
                }
            }
            
            
            bpmvalue.text = "\(data[0].bpm)"
            bpmvalue.sizeToFit()
            tempvalue.text = "\(data[0].temp.rounded(toPlaces: 1))"
            tempvalue.sizeToFit()
            gsrvalue.text = "\(data[0].returnRredictionGSRText())"
            gsrvalue.sizeToFit()
            gsrsublabel.text = "\(data[0].returnRredictionGSRString())"
            gsrsublabel.sizeToFit()
            
            let animDuration = Double(60)/Double(data[0].bpm)
            //change value of heartlayer animation
            heartAnimation.duration = CFTimeInterval(animDuration)
            heartPathAnimation.duration = CFTimeInterval(animDuration)
            heartLayer.removeAllAnimations()
            shapeLayer.removeAllAnimations()
            heartLayer.add(heartAnimation, forKey: #keyPath(CALayer.bounds))
            shapeLayer.add(heartPathAnimation, forKey: #keyPath(CAShapeLayer.path))

            
            
            //need to update height of the thermometer level. Scaling to between 15 and 40 as extreme ends for what my skin temp is likely to be.
            let nlev = data[0].temp.map(from: 15.0...40.0, to: 0...1.0)
            thermoview.level = CGFloat(nlev)
            var colorSet = [ #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor, #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor, #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor]
            if(nlev >= 0.1 && nlev < 0.2){
                colorSet = [ #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor, #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor, #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor]
            }
            if(nlev >= 0.2 && nlev < 0.3){
                colorSet = [ #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor, #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor]
            }
            if(nlev >= 0.3 && nlev < 0.4){
                colorSet = [ #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor, #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor]
            }
            if(nlev >= 0.4 && nlev < 0.5){
                colorSet = [ #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor, #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor, #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor]
            }
            if(nlev >= 0.5 && nlev < 0.6){
                colorSet = [ #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor, #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor]
            }
            if(nlev >= 0.6 && nlev < 0.7){
                colorSet = [ #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor, #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor]
            }
            if(nlev >= 0.7 && nlev < 0.8){
                colorSet = [ #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,   #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor, #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor, #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor]
            }
            if(nlev >= 0.8 && nlev < 0.9){
                colorSet = [ #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,   #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor, #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor, #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor]
            }
            if(nlev >= 0.9 && nlev <= 1.0){
                colorSet = [ #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor, #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor,  #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1).cgColor]
            }
            let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
            colorChangeAnimation.duration = 2.0
            colorChangeAnimation.toValue = colorSet
            colorChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
            colorChangeAnimation.isRemovedOnCompletion = false
            //gradLayer.add(colorChangeAnimation, forKey: "colorChange")
            gradLayer.colors = colorSet

            
            updateLocations()
            
        }
    }
    
    //
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //this SENDS data to the next one
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddItem":
            //this is not really actually a thing. should delete
            os_log("Adding a new prediction.", log: OSLog.default, type: .debug)
            
        case "ShowCorrectionDetail":
            guard let ShowCorrectionDetail = segue.destination as? CorrectionViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            //probably don't actually need this
            let selectedPrediction =
                thisPrediction
            ShowCorrectionDetail.prediction = selectedPrediction
            
        case "ShowConfirmationDetail":
            guard let ShowConfirmationDetail = segue.destination as? ConfirmationViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            //probably don't actually need this
            let selectedPrediction = thisPrediction
            ShowConfirmationDetail.prediction = selectedPrediction
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
            
        }
    }
    
    //MARK: Actions
    //this RECIEVES data from the previous one
    @IBAction func unwindToOverview(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ConfirmationViewController, let prediction = sourceViewController.prediction {
            thisPrediction = prediction
            if let thisPrediction = thisPrediction{
                if var ps = dataStack?.predictions{
                    let matches = ps.filter{
                        $0.time == thisPrediction.time
                    }
                    if(matches.count>0){
                        if let index = ps.firstIndex(of: matches[0]){
                            ps[index] = thisPrediction
                            dataStack?.savePredictions(predictions: ps)
                        }
                    }else{
                        ps.append(thisPrediction)
                        dataStack?.savePredictions(predictions: ps)
                    }
                }
            }
        } else if let sourceViewController = sender.source as? CorrectionViewController, let prediction = sourceViewController.prediction {
            thisPrediction = prediction
            if let thisPrediction = thisPrediction{
                if var ps = dataStack?.predictions{
                    ps.append(thisPrediction)
                    dataStack?.savePredictions(predictions: ps)
                }
            }
        }
    }
    //MARK: Private Methods

}

