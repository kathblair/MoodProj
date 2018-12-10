//
//  AppDelegate.swift
//  BarChart
//
//  Created by Nguyen Vu Nhat Minh on 19/8/17.
//  Copyright © 2017 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    
    var predictions: [Prediction] = [] // should build my sample ones here
    var notes: [Note] = [] // should build my sample ones here
    var data: [PhysData] = []


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        //need to build this
        //this worked. I think I'll just have problems the first time I want to make some predictions and save them.
        loadSamplePredictions()
        
        getFireBaseData { (values) -> Void in
            self.data = convertDictToPhysData(values: values)
            let dataStack = DataStack(data: self.data, predictions: self.predictions, notes: self.notes)
            //could I reset them here?
            if let tab = self.window?.rootViewController as? UITabBarController {
                    for child in tab.viewControllers ?? [] {
                        if let top = child as? DataProtocolClient {
                            if let dataStack = dataStack {
                                top.setData(data: dataStack)
                            }
                        }
                 }
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: Private Methods
    
    private func loadSamplePredictions() {
        // make one to load from the DB ... and one to save from a set of data to a prediction.
        let data1 = PhysData(millis: 1000, time: Date.init(timeIntervalSinceNow: -86400).timeIntervalSince1970, gsr: 1000, gsreval: PhysData.gsrstate.bo, bpm: 60, temp: 35)
        let data2 = PhysData(millis: 1100, time: Date.init(timeIntervalSinceNow: -76400).timeIntervalSince1970, gsr: 1100, gsreval: PhysData.gsrstate.bs, bpm: 65, temp: 30)
        let data3 = PhysData(millis: 1200, time: Date.init(timeIntervalSinceNow: -66400).timeIntervalSince1970, gsr: 1200, gsreval: PhysData.gsrstate.sf, bpm: 70, temp: 25)
        if let data1 = data1, let data2=data2, let data3=data3 {
            guard let prediction1 = Prediction(timecreated: Date.init(timeIntervalSinceNow: -100).timeIntervalSince1970, mood: Prediction.moods.happy, confirmed: true, note: "This is a note for prediction 1", dataPoint: data1) else {
                fatalError("Unable to instantiate prediction1")
            }
            guard let prediction2 = Prediction(timecreated: Date.init(timeIntervalSinceNow: -200).timeIntervalSince1970, mood: Prediction.moods.sad, confirmed: false, note: "This is a note for prediction 2", dataPoint: data2) else {
                fatalError("Unable to instantiate prediction2")
            }
            
            guard let prediction3 = Prediction(timecreated: Date.init(timeIntervalSinceNow: -100).timeIntervalSince1970,  mood: Prediction.moods.angry, confirmed: nil, note: "this is a note for prediction 3", dataPoint: data3) else {
                fatalError("Unable to instantiate prediction3")
            }
            self.predictions += [prediction1, prediction2, prediction3]
        }
    }
}

