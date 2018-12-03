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

class IntroViewController: UIViewController {
    let colors = [#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)]
    
    @IBOutlet weak var overviewTab: UITabBarItem!
    @IBOutlet weak var viewForLayer: UIView!
    
    //wonder if this is why I was having trouble???
    var layer: CALayer {
        return viewForLayer.layer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayer()
    }
    
    func setUpLayer() { // draws the components
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
        
        //gradient layer. colour will need to be based on data
        let gradLayer = CAGradientLayer()
        gradLayer.frame = CGRect(x: -4, y: -24, width: self.view.frame.width+4, height: self.view.frame.height+24)
        gradLayer.colors = [colors[3].cgColor, colors[4].cgColor]
        layer.addSublayer(gradLayer)
        
        // this will need to be changed based on data. I wonder when I should do the data getting. and see if I can make it public, when i should recheck it
        
        //draw the heart ... could make it a function?
        let heartLayer = CALayer()
        let heartw = (layer.frame.width*0.75)
        let hearth = layer.frame.height*0.5
        let heartx = ((layer.frame.width/2)-(heartw/2))+15
        let hearty = ((layer.frame.height/2)-(hearth/2))+(hearth/4)
        heartLayer.frame = CGRect(x: heartx, y: hearty, width: heartw, height: hearth)
        //heartLayer.backgroundColor = colors[5].cgColor
        
        let bezierPath = UIBezierPath(heartIn: heartLayer.bounds)

        //design path in layer
        let shapeLayer = CAShapeLayer()
        //shapeLayer.path = path.cgPath
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.strokeColor = colors[7].cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.fillColor = colors[5].cgColor
        shapeLayer.shadowOpacity = 0.7
        shapeLayer.shadowOffset = CGSize(width: 0, height:5.0)
        shapeLayer.shadowRadius = 10.0
        heartLayer.addSublayer(shapeLayer)
        
        layer.addSublayer(heartLayer)
        

        
        //in this context, this is the main label so I'm going to use it as the base, actually
        let bpmvalue = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
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
        
        //in this context, this is the main label so I'm going to use it as the base, actually
        let gsrvalue = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
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
        let thermoview = ThermometerView()
        self.view.addSubview(thermoview)
        
        //in this context, this is the main label so I'm going to use it as the base, actually
        let tempvalue = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
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
    
}

