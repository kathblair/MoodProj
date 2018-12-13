
import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    
    var predictions: [Prediction] = [] // should build my sample ones here
    var data: [PhysData] = []
    var dataStack: DataStack?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Use Firebase library to configure APIs
        FirebaseApp.configure()

        
        getFireBaseData { (values) -> Void in
            self.data = convertDictToPhysData(values: values)
            
            /*
            if let savedPredictions = self.dataStack?.loadPredictions() {
                print("successfully loaded predctions")
                self.predictions += savedPredictions
            } else {
                // Load the sample data.
                print("couldn't load predictions")
                self.loadSamplePredictions()
            }
             */
            //initialize with empty predictions
            self.dataStack = DataStack(data: self.data, predictions: self.predictions)
            if let dataStack = self.dataStack {
                let savedPredictions = dataStack.loadPredictions() // can I do this? Right now it doesn't need to be on the actual datastack
                if let savedPredictions = savedPredictions {
                    print("have saved predictions")
                    self.predictions = savedPredictions
                    dataStack.predictions = self.predictions
                }else{
                    print("no saved predictions")
                    self.predictions = self.loadSamplePredictions()
                    dataStack.predictions = self.predictions
                }
                
                //print(dataStack.predictions)
            }
            if let tab = self.window?.rootViewController as? UITabBarController {
                    for child in tab.viewControllers ?? [] {
                        if let top = child as? DataProtocolClient {
                            if let dataStack = self.dataStack {
                                top.setData(data: dataStack)
                            }
                        }
                 }
            }
    
            
            // Load any saved predictions, otherwise load sample data.
            // doing this after I pull from FB so I can easily add it when I have that done
            
           
            
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
        //should save data here
        if let dataStack = self.dataStack, let preds = dataStack.predictions {
            dataStack.savePredictions(predictions: preds)
        }
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("will terminate")
        if let dataStack = self.dataStack, let preds = dataStack.predictions {
            dataStack.savePredictions(predictions: preds)
        }
    }
    
    //MARK: Private Methods
    
    private func loadSamplePredictions()-> [Prediction] {
        // make one to load from the DB ... and one to save from a set of data to a prediction.
        print("Datas:\(self.data.count)")
        //I think they are all different, so that's good
        
        let data1 = self.data[0]
        let data2 = self.data[100]
        let data3 = self.data[200]
        //could append those to data and get them
        guard let prediction1 = Prediction(timecreated: Date.init(timeIntervalSinceNow: -100).timeIntervalSince1970, mood: Prediction.moods.happy, confirmed: true, note: "This is a note for prediction 1", time: data1.time, millis: data1.millis, gsr: data1.gsr, gsreval: data1.gsreval, bpm:data1.bpm, temp: data1.temp) else {
                fatalError("Unable to instantiate prediction1")
            }
        guard let prediction2 = Prediction(timecreated: Date.init(timeIntervalSinceNow: -200).timeIntervalSince1970, mood: Prediction.moods.sad, confirmed: false, note: "This is a note for prediction 2", time: data2.time, millis: data2.millis, gsr: data2.gsr, gsreval: data2.gsreval, bpm:data2.bpm, temp: data2.temp) else {
                fatalError("Unable to instantiate prediction2")
            }
            
        guard let prediction3 = Prediction(timecreated: Date.init(timeIntervalSinceNow: -100).timeIntervalSince1970,  mood: Prediction.moods.angry, confirmed: nil, note: "this is a note for prediction 3", time: data3.time, millis: data3.millis, gsr: data3.gsr, gsreval: data3.gsreval, bpm:data3.bpm, temp: data3.temp) else {
                fatalError("Unable to instantiate prediction3")
            }
        let predictions = [prediction1, prediction2, prediction3]
        print("ok added sample predictions")
        return predictions
    }
}

