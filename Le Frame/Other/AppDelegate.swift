//
//  AppDelegate.swift
//  Le Frame
//
//  Created by Saar Botzer on 09/10/2019.
//  Copyright © 2019 Saar Botzer. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window : UIWindow?
    let defaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        getAppVersionAndBuild()
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        FirebaseApp.configure()

        Auth.auth().signInAnonymously { (authResult, error) in
            guard let user = authResult?.user else {
                self.defaults.set(UUID().uuidString, forKey: "uuid")
                return
            }
            _ = user.isAnonymous  // let isAnonymous
            let uid = user.uid // let uid
            self.defaults.set(uid, forKey: "uuid")
        }
        
        _ = Firestore.firestore() // let db
                
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
    }
    

    func applicationWillTerminate(_ application: UIApplication) {
        
        // TODO: Save current game data
        print("applicationWillTerminate")
        self.saveContext()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
    }
    

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Data Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                 
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getAppVersionAndBuild() {
        var versionString = "Unknown"
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionString = "\(appVersion) (\(appBuild))"
        }
        
        defaults.set(versionString, forKey: "appVersion")
    }
}

