//
//  AppDelegate.swift
//  ColumnText
//
//  Created by Sureshbabu Naidu on 19/01/17.
//  Copyright © 2017 Vishwak Sol pvt. ltd. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //    let temp = self.dataArray.count
    //    newsArticleCount = self.dataArray.count
    //    self.searchedDataArray = self.dataArray
    //    var j = 5
    //    while j < temp {
    //        let dict = NSDictionary()
    //        print("advertizement cell index value:\(j)")
    //        self.dataArray.insert(dict as! [String:Any], at: j)
    //        j = j + 6
    //    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let arrayValue = [1,2,3,4,5,6,7,8,9,0,12,23]
        var j = 5
        let temp = arrayValue.count
        var totalSum = 0
        while j < temp {
            let indexValue = arrayValue[j]
            totalSum = totalSum + indexValue
            j = j + 6
        }
        print(totalSum)
        let str = "H"
        let att = (str.utf8Data?.attributedStringColumnWise!)! as NSAttributedString
        print(att)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            // Your code to run after 10 seconds
//            let str = "H"
//            print(str.utf8Data?.attributedStringColumnWise! as Any)
//        }
        
        
        // Override point for customization after application launch.
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


}

