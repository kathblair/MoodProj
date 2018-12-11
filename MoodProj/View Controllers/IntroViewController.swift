//
//  IntroViewController.swift
//  MoodProj
//
//  Created by Kathryn Blair on 2018-11-20.
//  Copyright © 2018 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit
import Firebase
import os.log

class IntroViewController: UIViewController, DataProtocolClient {
    let colors = [#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)]
    

    
    @IBOutlet weak var overviewTab: UITabBarItem!
    @IBOutlet weak var viewForLayer: UIView!
    @IBOutlet weak var moodLabel: UILabel!
    
    //wonder if this is why I was having trouble???
    var layer: CALayer {
        return viewForLayer.layer
    }
    
    //putting the things I need to edit so I can access from the update function
    //in this context, this is the main label so I'm going to use it as the base, actually
    let bpmvalue = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    //gradient layer. colour will need to be based on data
    let gradLayer = CAGradientLayer()
    //in this context, this is the main label so I'm going to use it as the base, actually
    let gsrvalue = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    //in this context, this is the main label so I'm going to use it as the base, actually
    let tempvalue = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    let thermoview = ThermometerView()
    let heartLayer = CALayer()
    let heartAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.bounds))
    let heartPathAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
    let shapeLayer = CAShapeLayer()
    
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
        print("navigating away from Overview")
        //decide if I want to save this prediction, and if so, save them.
        if let pred = thisPrediction, let dataStack = dataStack, let _ = dataStack.predictions {
            print("have a thisPrediction")
            print(pred.note) //it's not getting sent down
        }
        //print(preds[0].timecreated)
        //print(preds[preds.count-1].timecreated)
        //oh yeah the predictions aren't sorted because I haven't called them from the database anyway, so I should fix this when I have that done correctly. Maybe I will persist data and then do those things. And I can make the other ones in the past.
    }

    func setUpLayer() { // draws the components
        //print("in setup layer")
        // navigation, need to add to all frames and probably put in a function
        /*
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        self.view.addSubview(navBar);
        let navItem = UINavigationItem(title: "Overview");
        
        let timelineItem = UIBarButtonItem
        navItem.rightBarButtonItem = doneItem;
        
        navBar.setItems([navItem], animated: false);
         */
        
        
        //should probably make this into a class
        
        layer.backgroundColor = UIColor.blue.cgColor
        //layer.borderWidth = 10.0
        //layer.borderColor = UIColor.green.cgColor
        //layer.shadowOpacity = 0.7
        //layer.shadowRadius = 10.0
        print(layer.frame.width)
        print(layer.frame.height)
        
        
        gradLayer.frame = CGRect(x: -4, y: -24, width: self.view.frame.width+4, height: self.view.frame.height+24)
        gradLayer.colors = [colors[3].cgColor, colors[4].cgColor]
        layer.addSublayer(gradLayer)
        
        // this will need to be changed based on data. I wonder when I should do the data getting. and see if I can make it public, when i should recheck it
        
        //draw the heart ... could make it a function?
        let heartw = (layer.frame.width*0.75)
        let hearth = layer.frame.height*0.5
        let heartx = ((layer.frame.width/2)-(heartw/2))+15
        let hearty = ((layer.frame.height/2)-(hearth/2))+(hearth/4)
        heartLayer.frame = CGRect(x: heartx, y: hearty, width: heartw, height: hearth)
        //heartLayer.backgroundColor = colors[5].cgColor
        
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
        heartAnimation.duration = 1.0
        heartAnimation.repeatCount = .greatestFiniteMagnitude
        heartAnimation.autoreverses = true
        heartLayer.bounds = newbValue
        
        let newPath = UIBezierPath(heartIn: heartLayer.bounds)
        heartPathAnimation.fromValue = shapeLayer.path
        heartPathAnimation.toValue = newPath.cgPath
        heartPathAnimation.duration = 1.0
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
        bpmvalue.text = "65"
        bpmvalue.sizeToFit()
        bpmvalue.center = CGPoint(x: heartLayer.position.x+5, y: heartLayer.position.y+heartLayer.frame.height/16)
        self.view.addSubview(bpmvalue)
        
        //add labels
        let bpmlabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        // you will probably want to set the font (remember to use Dynamic Type!)
        bpmlabel.font = UIFont.preferredFont(forTextStyle: .title1)
        bpmlabel.textColor = .white
        bpmlabel.center = CGPoint(x: bpmvalue.center.x, y: bpmvalue.center.y-bpmvalue.frame.height/2)
        bpmlabel.textAlignment = .center
        bpmlabel.text = "BPM:"
        self.view.addSubview(bpmlabel)
        
        //draw the droplet
        let dropLayer = CALayer()
        let dropw = (layer.frame.width*0.15)
        let droph = (layer.frame.width*0.15)
        let dropx = layer.bounds.minX+20
        let dropy = (layer.bounds.maxY+50)
        dropLayer.frame = CGRect(x: dropx, y: dropy, width: dropw, height: droph)
        //heartLayer.backgroundColor = colors[5].cgColor
        
        //LOOK AT THAT IT KINDA WORKED
        let dropbezierPath = UIBezierPath(dropIn: dropLayer.bounds)
        
        //design path in layer
        let dropshapeLayer = CAShapeLayer()
        //shapeLayer.path = path.cgPath
        dropshapeLayer.path = dropbezierPath.cgPath
        //dropshapeLayer.strokeColor = colors[7].cgColor
        dropshapeLayer.lineWidth = 2.0
        dropshapeLayer.fillColor = colors[1].cgColor
        //dropshapeLayer.shadowOpacity = 0.7
        //dropshapeLayer.shadowOffset = CGSize(width: 0, height:5.0)
        //dropshapeLayer.shadowRadius = 10.0
        dropLayer.addSublayer(dropshapeLayer)
        
        layer.addSublayer(dropLayer)
        

        // you will probably want to set the font (remember to use Dynamic Type!)
        gsrvalue.font = UIFont.preferredFont(forTextStyle: .title1)
        gsrvalue.font = bpmvalue.font.withSize(70)
        gsrvalue.textColor = .white
        gsrvalue.textAlignment = .center
        // need to get programatically, also after we've actually gotten the data
        // plus i need to animate the heart
        gsrvalue.text = "SP"
        gsrvalue.sizeToFit()
        gsrvalue.center = CGPoint(x: dropLayer.position.x+5, y: dropLayer.position.y+dropLayer.frame.height/16)
        self.view.addSubview(gsrvalue)
        
        //add labels
        let gsrlabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        // you will probably want to set the font (remember to use Dynamic Type!)
        gsrlabel.font = UIFont.preferredFont(forTextStyle: .title1)
        gsrlabel.textColor = .white
        gsrlabel.center = CGPoint(x: gsrvalue.center.x, y: gsrvalue.center.y-gsrvalue.frame.height/2)
        gsrlabel.textAlignment = .center
        gsrlabel.text = "GSR:"
        self.view.addSubview(gsrlabel)
        
        // now I need to add the labels for that, but let's see about the thermometer
        // doing that in the designer isn't working. But I can see it.
        self.view.addSubview(thermoview)
        
        // you will probably want to set the font (remember to use Dynamic Type!)
        tempvalue.font = UIFont.preferredFont(forTextStyle: .title1)
        tempvalue.font = bpmvalue.font.withSize(70)
        tempvalue.textColor = .white
        tempvalue.textAlignment = .center
        // need to get programatically, also after we've actually gotten the data
        // plus i need to animate the heart
        tempvalue.text = "29"
        tempvalue.sizeToFit()
        tempvalue.center = CGPoint(x: screenWidth*0.75, y: screenHeight*0.75)
        self.view.addSubview(tempvalue)
        
        //add labels
        let templabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        // you will probably want to set the font (remember to use Dynamic Type!)
        templabel.font = UIFont.preferredFont(forTextStyle: .title1)
        templabel.textColor = .white
        templabel.center = CGPoint(x: tempvalue.center.x, y: tempvalue.center.y-tempvalue.frame.height/2)
        templabel.textAlignment = .center
        templabel.text = "Temp:"
        self.view.addSubview(templabel)
    }

    //updates the layer data.
    func updateLayer(){
        //Making the prediction
        //Maybe move this above and check it in updateprediction and see if we need to do anything with it
        if let dataStack = dataStack, let data = dataStack.data, let preds = dataStack.predictions {
            
            predictedMood = data[0].returnMoodPrediction(baseline: dataStack.baseline)
            
            //also I should see when the last prediction is and save it if it was like X mins ago ...
            if let predictedMood = predictedMood {
                print(predictedMood)
                thisPrediction = Prediction(timecreated: NSDate().timeIntervalSince1970, mood: predictedMood, confirmed: false, note: "", time: data[0].time, millis: data[0].millis, gsr: data[0].gsr, gsreval:data[0].gsreval, bpm: data[0].bpm, temp: data[0].temp)
                //false because it's not been confirmed in the popup yet
                moodLabel.text = "\(predictedMood)"
            }
            
            bpmvalue.text = "\(data[0].bpm)"
            //get the prev centre and move the new centre to it
            bpmvalue.sizeToFit()
            tempvalue.text = "\(data[0].temp)"
            //get the prev centre and move the new centre to it
            tempvalue.sizeToFit()
            
            let animDuration = 60/data[0].bpm
            
            //change value of heartlayer animation
            heartAnimation.duration = CFTimeInterval(animDuration)
            heartPathAnimation.duration = CFTimeInterval(animDuration)
            heartLayer.removeAllAnimations()
            shapeLayer.removeAllAnimations()
            heartLayer.add(heartAnimation, forKey: #keyPath(CALayer.bounds))
            shapeLayer.add(heartPathAnimation, forKey: #keyPath(CAShapeLayer.path))

            
            
            //need to update height of the templayer thing .... not sure how to like scale this.
            //also right now I'm not looking at this to update it, duh. Add that.
            //just scale 0-100. Should probably change to make it more similar to what it would be
            let nlev = data[0].temp.map(from: 0.0...100.0, to: 0...1.0)
            //print("nlev = \(nlev)")
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
            
            //and need to make a prediction.
            //I should put this on a function on physdata
            //now I can check this
           
            //now show it ... ok and how do I add the info to it ... I can probably do that stuff up at the top anyway really
            
            
            
            //gsrvalue.text = "\(data[0].gsreval)"
            //gsrvalue.text = "sp"
            //get the prev centre and move the new centre to it
            //gsrvalue.sizeToFit()
            
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
        print("unwinding")
        if let sourceViewController = sender.source as? ConfirmationViewController, let prediction = sourceViewController.prediction {
            thisPrediction = prediction
            if let thisPrediction = thisPrediction{
                if var ps = dataStack?.predictions{
                    ps.append(thisPrediction)
                    dataStack?.savePredictions(predictions: ps)
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

