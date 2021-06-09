//
//  DreamTeamApp.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 12/15/20.
//

import SwiftUI

@main

struct DreamTeamApp: App {
    
    @StateObject var sceneManager = SceneManager()
    
    // To fix: the question to allow notifications shows up before you even sign in, even if you select "Allow" the permission granted here in xocde says false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            if sceneManager.state == "Signed In" {
                FeedView().environmentObject(sceneManager)
            } else {
                SignInView().environmentObject(sceneManager)
            }
            
        }
    }
}
