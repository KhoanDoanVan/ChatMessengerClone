//
//  MessengerCloneApp.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 24/7/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      /// Config Firebase
      FirebaseApp.configure()
      
      /// Config Online State
      
      trackAuthStateChanges()
    return true
  }
    
    /// Tracking Auth State to ensure Firebase is ready
        private func trackAuthStateChanges() {
            Auth.auth().addStateDidChangeListener { auth, user in
                if let user = user {
                    // User is logged in
                    print("User is logged in, tracking online state for user: \(user.uid)")
                    self.trackingUserOnlineState(for: user.uid)
                } else {
                    // User is not logged in
                    print("No user is currently logged in.")
                }
            }
        }
}

@main
struct MessengerCloneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

extension AppDelegate {
    
    /// Config Online User State
        private func trackingUserOnlineState(for userCurrentUid: String) {
            print("Tracking online state for user: \(userCurrentUid)")
            
            let userRef = FirebaseConstants.UserRef.child(userCurrentUid)
                        
            /// Listen for connection state
            let connectRef = Database.database().reference(withPath: ".info/connected") // Use `.info/connected` to track connection state
            connectRef.observe(.value) { snapshot,_  in
                if let connected = snapshot.value as? Bool, connected {
                    /// If connected
                    userRef.child("isOnline").setValue(true)
                    
                    /// Set isOnline to false automatically when the connection is lost (app closes or goes offline)
                    userRef.child("isOnline").onDisconnectSetValue(false)
                    userRef.child("lastActive").onDisconnectSetValue(ServerValue.timestamp())
                    print("Successfully connected to .info/connected")
                } else {
                    print("Failed to connect to .info/connected")
                }
            }
            
            print("Out of the connectRef")
        }
    
    /// Goes into background
    internal func applicationDidEnterBackground(_ application: UIApplication) {
        guard let userCurrentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserRef.child(userCurrentUid).child("isOnline").setValue(false)
        FirebaseConstants.UserRef.child(userCurrentUid).child("lastActive").setValue(ServerValue.timestamp())
        print("Back ground active")
    }
    
    /// When app becomes active again
    internal func applicationWillEnterForeground(_ application: UIApplication) {
        guard let userCurrentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserRef.child(userCurrentUid).child("isOnline").setValue(true)
        print("Active again")
    }
    
    /// When app is terminated
    internal func applicationWillTerminate(_ application: UIApplication) {
        guard let userCurrentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserRef.child(userCurrentUid).child("isOnline").setValue(false)
        FirebaseConstants.UserRef.child(userCurrentUid).child("lastActive").setValue(ServerValue.timestamp())
        print("Terminated")
    }
}
