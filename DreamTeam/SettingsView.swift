//
//  SettingsView.swift
//  DreamTeam
//
//  Created by Lauren Sullivan on 2/5/21.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var userSettings = UserSettings()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var userId: String = ""
    @State private var userToken: String = ""
    @State private var userAuth = AuthResponse()
    
    var body: some View {
        
        VStack {
            Form {
                Section(header: Text("Previous User?")) {
                    TextField("User ID", text: $userId)
                        .keyboardType(.default)
                    TextField("Token", text: $userToken)
                        .keyboardType(.default)
                }
                
                Button("Save") {
                    changeUser()
                }
            }
            HStack {
                Text("Your timezone:")
                Text(userSettings.localTimeZoneIdentifier)
            }
        }
    }
    
    func changeUser() {
        guard let url = URL(string: "http://34.208.204.33:8080/users/" + "\(userId)" + "/authenticate?token=" + "\(userToken)") else {
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
                            self.presentationMode.wrappedValue.dismiss()
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
