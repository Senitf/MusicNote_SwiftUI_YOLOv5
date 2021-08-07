//
//  MusicPenApp.swift
//  MusicPen
//
//  Created by 김민호 on 2021/08/07.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct MusicPenApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}


class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])-> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
}
