//
//  AppDelegate.swift
//  ReaddleDemo
//
//  Created by Ivan Bolgov on 06.06.2022.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let storage = FileStortage()
        let mainCoordinator = GalleryCoordinator(
            window: window!,
            delegate: self,
            provider: GoogleDiskImageProvider(service: GTLRDriveService(), storage: storage),
            storage: storage)
        mainCoordinator.start()
        
        return true
    }
}

extension AppDelegate: GalleryCoordinatorDelegate {
    func didFinishGalleryCoordinator() {
        
    }
}
