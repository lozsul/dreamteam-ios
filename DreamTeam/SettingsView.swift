//
//  SettingsView.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 2/5/21.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var sceneManager: SceneManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person")
                            .frame(width: 30)
                        Text("Profile")
                    }
                    NavigationLink(destination: TeamsView()) {
                        Image(systemName: "person.2")
                            .frame(width: 30)
                        Text("Teams")
                    }
                    NavigationLink(destination: FeedbackView(userSettings: UserSettings())) {
                        Image(systemName: "text.bubble")
                            .frame(width: 30)
                        Text("Feedback")
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .background(Color(.systemGroupedBackground))
                .edgesIgnoringSafeArea(.all)
            }
            .onAppear(perform: dismiss)
            .navigationBarTitle("Settings", displayMode: .inline)
        }
    }
    
    func dismiss() {
        if sceneManager.state != "Signed In" {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
