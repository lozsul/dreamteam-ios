//
//  ProfileView.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 3/2/21.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var sceneManager: SceneManager
    @ObservedObject var userSettings = UserSettings()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var userId: String = ""
    @State private var userToken: String = ""
    @State private var userAuth = AuthResponse()
    @State private var isPreviousUser: Bool = false
    
    var body: some View {
        VStack {
            Form {
                
                Section(header: Text("Name")) {
                    TextField(userSettings.name, text: $userName)
                        .disabled(true)
                }
                
                Section(header: Text("Email")) {
                    TextField(userSettings.email, text: $userEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disabled(true)
                }
                
                Section(header: Text("Timezone")) {
                    Text(userSettings.localTimeZoneIdentifier)
                        .disabled(true)
                }
                
                Button("Sign out") {
                    signOut()
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarTitle("Profile", displayMode: .inline)
    }
    
    func signOut() {
        userSettings.id = 0
        userSettings.token = ""
        userSettings.name = ""
        userSettings.email = ""
        sceneManager.state = ""
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func updateUser() {
        
        // Need to change this code from logging in as another user, to updating the current user's info
        
        guard let url = URL(string: "http://34.208.204.33:8080/users/" + "authenticate?token=" + "\(userToken)") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(AuthResponse.self, from: data)
                    DispatchQueue.main.async {
                        if response.authenticated {
                            // Set user defaults
                            UserDefaults.standard.set(self.userId, forKey: "id")
                            UserDefaults.standard.set(self.userToken, forKey: "token")
                            
                            // Refresh feed
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("FeedRefresh"), object: nil)
                            }
                            
                            // Close window
                            //self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                } catch let jsonError as NSError {
                    print("\(jsonError.localizedDescription)")
                }
              return
            }
        }.resume()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
