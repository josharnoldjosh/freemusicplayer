//
//  AppDelegate.swift
//  freemusic
//
//  Created by Josh Arnold on 18/05/17.
//  Copyright © 2017 Josh Arnold. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds

var backgroundModeEnabled:Bool! = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    ///Audio session
    let audioSession:AVAudioSession! = AVAudioSession.sharedInstance()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Audio session
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        } catch _ {
            print("error setting audio!")
        }
        
        GADMobileAds.configure(withApplicationID: "ca-app-pub-4325909828247369~7812733931")
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        backgroundModeEnabled = true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        backgroundModeEnabled = false
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
}

